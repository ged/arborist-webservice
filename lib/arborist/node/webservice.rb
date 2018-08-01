# -*- ruby -*-
#encoding: utf-8

require 'loggability'

require 'arborist'
require 'arborist/webservice'
require 'arborist/node/service' unless defined?( Arborist::Node::Service )


# A web-service node type for Arborist
class Arborist::Node::Webservice < Arborist::Node::Service
	extend Loggability


	# The default HTTP verb to use for monitoring requests
	DEFAULT_HTTP_METHOD = 'HEAD'

	# The default HTTP status code to expect from responses
	DEFAULT_EXPECTED_STATUS = 200

	# The default Content-type to use for requests with a body
	DEFAULT_BODY_MIMETYPE = 'text/plain'


	# Loggability API -- use the logger for this library
	log_to :arborist_webservice

	# Webservices live under Host nodes
	parent_type :host


	### Create a new Webservice node.
	def initialize( identifier, host, uri, attributes={}, &block )
		@uri = uri
		uri_obj = URI( uri )

		attributes[:app_protocol] ||= uri_obj.scheme
		attributes[:port] ||= uri_obj.port
		attributes[:protocol] = 'tcp'
		attributes[:app_protocol] = 'http'
		attributes[:http_method] ||= DEFAULT_HTTP_METHOD
		attributes[:expected_status] ||= DEFAULT_EXPECTED_STATUS
		attributes[:body] ||= ''
		attributes[:body_mimetype] ||= DEFAULT_BODY_MIMETYPE

		self.log.debug "Supering with attributes: %p " % [ attributes ]
		super( identifier, host, attributes, &block )
	end


	######
	public
	######

	##
	# The URI of an endpoint that can be used to monitor the webservice
	dsl_accessor :uri

	##
	# The http_method used by the service
	dsl_accessor :http_method

	##
	# The expected_status used by the service
	dsl_accessor :expected_status

	##
	# The body used by the service
	dsl_accessor :body

	##
	# The body_mimetype used by the service
	dsl_accessor :body_mimetype


	### Set node +attributes+ from a Hash.
	def modify( attributes )
		attributes = stringify_keys( attributes )

		super

		self.uri( attributes['uri'] )
		self.http_method( attributes['http_method'] )
		self.expected_status( attributes['expected_status'] )
		self.body( attributes['body'] )
		self.body_mimetype( attributes['body_mimetype'] )
	end


	### Returns +true+ if the node matches the specified +key+ and +val+ criteria.
	def match_criteria?( key, val )
		self.log.debug "Matching %p: %p against %p" % [ key, val, self ]
		return case key
			when 'uri'
				URI( self.uri ) == URI( val )
			when 'http_method'
				self.http_method == val
			when 'expected_status'
				self.expected_status == val
			when 'body'
				self.body == val
			when 'body_mimetype'
				self.body_mimetype == val
			else
				super
			end
	end


	### Return a Hash of the operational values that are included with the node's
	### monitor state.
	def operational_values
		return super.merge(
			uri: self.uri,
			http_method: self.http_method,
			expected_status: self.expected_status,
			body: self.body,
			body_mimetype: self.body_mimetype
		)
	end


	### Return service-node-specific information for #inspect.
	def node_description
		desc = "%s %s %s/1.1" % [
			self.http_method,
			self.uri,
			self.app_protocol.upcase,
		]

		if body && !body.empty?
			desc << " {%s} (%s)" % [ self.body, self.body_mimetype ]
		end

		desc << ' -> %d response' % [ self.expected_status.to_i ]

		return desc
	end


	### Serialize the resource node.  Return a Hash of the host node's state.
	def to_h( * )
		return super.merge(
			uri: self.uri,
			http_method: self.http_method,
			expected_status: self.expected_status,
			body: self.body,
			body_mimetype: self.body_mimetype
		)
	end


	#######
	private
	#######

	### Make an identifier from the specified +url+.
	def make_identifier_suffix( url )
		return url.to_s.gsub( /\W+/, '-' )
	end


end # class Arborist::Node::Webservice

