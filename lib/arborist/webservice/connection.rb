# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'socket'
require 'openssl'
require 'uri'

require 'arborist/webservice' unless defined?( Arborist::Webservice )
require 'arborist/webservice/constants'
require 'arborist/mixins'

using Arborist::TimeRefinements


class Arborist::Webservice::Connection
	extend Loggability
	include Arborist::Webservice::Constants

	# The states in which the underlying socket should be selected as readable
	READABLE_STATES = %i[
		request_written
	]

	# Which string to use as the end-of-line
	EOL = "\r\n"


	# Loggability
	log_to :arborist_webservice


	### Create a new Connection object according to the specified +node_data+.
	def self::from_node_data( node_data )
		self.log.debug "Creating webservice connection for %p" % [ node_data ]

		options = {}
		options[:uri]          = URI( node_data['uri'] )
		options[:http_method]  = node_data['http_method']
		options[:http_version] = node_data['http_version']
		options[:headers]      = self.make_headers_hash( node_data )
		options[:ssl_context]  = self.make_ssl_context( options[:uri], node_data )
		options[:body]         = node_data['body']

		return new( **options )
	end


	### Make an OpenSSL::Context if the +node_data+ indicates the connection should
	### use SSL and return it. Returns +nil+ if SSL shouldn't be used.
	def self::make_ssl_context( uri, node_data )
		return nil unless uri.scheme == 'https'

		context = OpenSSL::SSL::SSLContext.new

		ssl_attributes = SSL_ATTRIBUTES.each_with_object({}) do |key, ssl_key|
			ssl_attributes[ ssl_key ] = node_data[ key.to_s ] if
				node_data.key?( key.to_s )
		end
		context.set_params( ssl_attributes )

		return context
	end


	### Extract header values from the node_data, combine them with the defaults,
	### and return them as a Hash.
	def self::make_headers_hash( node_data )
		headers = DEFAULT_HTTP_HEADERS.merge( node_data['http_headers'] || {} )
		headers = headers.merge(
			'Content-type' => node_data['body_mimetype'],
			'Content-length' => node_data['body']&.bytesize || 0
		)

		return headers
	end


	### Create a new Connection that will manage the request/response for the
	### specified uri, http_method, headers, ssl_context, and body.
	def initialize( uri:, **options )
		@uri             = uri
		@http_method     = options[:http_method] || DEFAULT_HTTP_METHOD
		@http_version    = options[:http_version] || DEFAULT_HTTP_VERSION
		@headers         = options[:headers] || {}
		@ssl_context     = options[:ssl_context]
		@request_body    = options[:request_body]

		@socket          = nil
		@ssl_socket      = nil
		@state           = nil
		@connect_started = nil
		@response_data   = nil
		@response_hash   = nil
	end


	##
	# The body of the request as a String
	attr_reader :request_body

	##
	# The state that indicates how far along in the process of reading the response
	# the connection is
	attr_accessor :state

	##
	# The Time the connection was started
	attr_accessor :connect_started

	##
	# The OpenSSL::SSL::SSLContext associated with the connection
	attr_accessor :ssl_context

	##
	# The URI of the connection
	attr_reader :uri

	##
	# The name of the HTTP method to use for the request
	attr_reader :http_method

	##
	# The HTTP version to use in the request line; note that this does not change
	# how the protocol used to send the request
	attr_reader :http_version


	### Return either the plain socket, or the SSL-wrapped one if the connection is
	### over SSL.
	def socket
		return @ssl_socket || @socket
	end


	### Return the underlying IO for this connection.
	def to_io
		return self.socket&.to_io
	end


	### Attempt to progress the connection until the response can be read, returning
	### it if it is possible. If it is not possible, progress as far as possible and
	### return nil. If there is an exception while trying to read, it is re-raised.
	def process_request
		case self.state
		when nil
			self.start_connecting
			return false
		when :connecting
			self.wrap_connection
			return false
		when :connected
			self.send_request
			return false
		when :request_written
			return self.fetch_response
		else
			raise "Unknown connection state %p: aborting" % [ self.state ]
		end
	end


	### Return +true+ if the connection should be read from, and so should be included
	### in the "readers" part of the select(2) when waiting for it to become ready.
	def readable?
		return READABLE_STATES.include?( self.state )
	end


	### Start the connection to the remote server without blocking.
	def start_connecting
		# :TODO: Should this try all the addresses? Should you be able to specify an
		# address for a Service?
		address = self.uri.host
		port = self.uri.port
		sockaddr = nil

		self.log.debug "Creating TCP connection for %s:%d" % [ address, port ]
		@socket = Socket.new( :INET, :STREAM )

		begin
			sockaddr = Socket.sockaddr_in( port, address )
			@socket.connect_nonblock( sockaddr )
		rescue Errno::EINPROGRESS
			self.state = :connecting
			self.log.debug "  connection started"
		end
	end


	### Upgrade the connection to TLS/SSL if applicable.
	def wrap_connection
		if self.ssl_context && !@ssl_socket
			@ssl_socket = OpenSSL::SSL::SSLSocket.new( @socket, self.ssl_context )
			@ssl_socket.hostname = self.uri.host
			@ssl_socket.sync_close = true

			begin
				socket.connect_nonblock
			rescue Errno::EINPROGRESS
				self.state = :connected
				self.log.debug "  SSL connection started"
			end
		else
			self.log.debug "connected with no SSL wrapper"
			self.state = :connected
		end
	end


	### Return the data to send as the request.
	def request_data
		data = "%s %s HTTP/%s" % [ self.http_method, self.uri.request_uri, self.http_version ]
		data << EOL
		data << self.header_data
		data << EOL
		data << self.request_body << EOL if self.request_body

		return data
	end


	### Return the request headers as as a String.
	def header_data
		return self.headers.each_with_object( '' ) do |(key, val), data|
			data << "%s: %s" % [ key, val ]
			data << EOL
		end
	end


	### Form the request and send it to the remote server.
	def send_request
		data = self.request_data
		self.log.debug "Writing the request to the socket: %p" % [ data ]
		self.socket.write_nonblock( data )
		self.state = :request_written
	end


	### Fetch the HTTP response as a Hash, reading it from the socket if it hasn't
	### been already. Returns +nil+ if the complete response hasn't been read yet.
	def fetch_response
		self.read_response unless @response_hash
		return @response_hash
	end


	### Read response data from the socket and append it to the response buffer.
	### When the socket is done reading, parse it into the response hash.
	def read_response
		
	end

end # class Arborist::Webservice::Connection

