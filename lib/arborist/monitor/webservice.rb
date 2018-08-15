# -*- ruby -*-
#encoding: utf-8

require 'thread'
require 'openssl'

require 'arborist'
require 'arborist/mixins'
require 'arborist/monitor' unless defined?( Arborist::Monitor )
require 'arborist/monitor/connection_batching'

require 'arborist/webservice'
require 'arborist/webservice/constants'
require 'arborist/webservice/connection'


using Arborist::TimeRefinements


# A web-service monitor type for Arborist
module Arborist::Monitor::Webservice
	extend Configurability
	include Arborist::Webservice::Constants


	configurability( 'arborist.monitors.webservice' ) do

		##
		# The default timeout employed by the socket monitors, in floating-point
		# seconds.
		setting :default_timeout, default: 2.0 do |val|
			Float( val )
		end

	end



	# Arborist HTML web service monitor logic
	class HTML
		extend Loggability
		include Arborist::Monitor::ConnectionBatching


		log_to :arborist_webservice


		# Defaults for instances of this monitor
		DEFAULT_OPTIONS = {
			timeout: 5.seconds
		}

		# The array of node properites used by this monitor
		NODE_PROPERTIES = %i[ uri http_method body body_mimetype ].freeze


		### Return an array of attributes to fetch from nodes for this monitor.
		def self::node_properties
			return NODE_PROPERTIES
		end


		### Instantiate a monitor check and run it for the specified +nodes+.
		def self::run( nodes )
			return self.new.run( nodes )
		end


		### Create a new HTML webservice monitor with the specified +options+. Valid options are:
		###
		### +:timeout+
		###   Set the number of seconds to wait for a connection for each node.
		def initialize( timeout: Arborist::Monitor::Webservice.default_timeout )
			self.timeout = timeout
		end


		######
		public
		######

		# The timeout for connecting, in seconds.
		attr_accessor :timeout


		### Return a clone of this object with its timeout set to +new_timeout+.
		def with_timeout( new_timeout )
			copy = self.clone
			copy.timeout = new_timeout
			return copy
		end


		### Return an Enumerator that lazily yields Hashes of the form expected by the
		### ConnectionBatching mixin for each of the specified +nodes+.
		def make_connections_enum( nodes )
			return nodes.lazy.map do |identifier, node_data|
				conn = nil
				begin
					conn = Arborist::Webservice::Connection.from_node_data( node_data )
					conn.start_connecting
				rescue => err
					self.log.error "  %p setting up connection: %s" % [ err.class, err.message ]
					conn = err
				end

				{ conn: conn, identifier: identifier }
			end
		end


		### Wait for one of the current connections to become "ready"; overridden to handle
		### reading and writing.
		def wait_for_ready_connections( wait_seconds )
			sockets_w = self.connection_hashes.keys
			sockets_r = sockets.select( &:readable? )

			ready = nil

			self.log.debug "Selecting on %d sockets." % [ sockets_r.length ]
			readable, writable, _ = IO.select( sockets_r, sockets_w, nil, wait_seconds ) unless
				sockets_r.empty?

			ready = (writable & readable).find_all {|conn| conn.process_request }

			return ready
		end


		### Build a status for the specified +conn_hash+ after its :conn has indicated
		### it is ready.
		def status_for_conn( conn_hash, duration )
			conn = conn_hash[:conn]
			res = conn.

			return {
				tcp_socket_connect: { duration: duration }
			}
		rescue SocketError, SystemCallError => err
			self.log.debug "Got %p while connecting to %s" % [ err.class, conn_hash[:identifier] ]
			begin
				sock.read( 1 )
			rescue => err
				return { error: err.message }
			end
		ensure
			sock.close if sock
		end

	end # class HTML


	# Arborist REST webservice monitor logic
	class REST < Arborist::Monitor::Webservice::HTML
	end # class REST

end # class Arborist::Monitor::Webservice

