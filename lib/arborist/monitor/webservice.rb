# -*- ruby -*-
#encoding: utf-8

require 'typhoeus'

require 'arborist'
require 'arborist/mixins'
require 'arborist/monitor' unless defined?( Arborist::Monitor )

require 'arborist/webservice'
require 'arborist/webservice/constants'


using Arborist::TimeRefinements


# A web-service monitor type for Arborist
module Arborist::Monitor::Webservice
	extend Configurability


	configurability( 'arborist.monitors.webservice' ) do

		##
		# The default timeout employed by the socket monitors, in floating-point
		# seconds.
		setting :default_timeout, default: 2.0 do |val|
			Float( val )
		end

		##
		# The maximum number of ongoing HTTP requests
		setting :max_concurrency, default: 100 do |val|
			Integer( val )
		end

		##
		# Whether or not to enable SSL peer certificate verification by default. The
		# value is either `1` to enable it by default, or `0` to disable it by default.
		# The config of each invidual webservice node can override this.
		setting :ssl_verifypeer, default: 1 do |val|
			Integer( val ).nonzero? ? 1 : 0
		end

	end



	# Arborist HTTP web service monitor logic
	class HTTP
		extend Loggability
		include Arborist::Webservice::Constants


		log_to :arborist_webservice


		# Defaults for instances of this monitor
		DEFAULT_OPTIONS = {
			timeout: 5.seconds
		}

		# The array of node properites used by this monitor
		NODE_PROPERTIES = %i[ uri http_method body body_mimetype config ].freeze


		### Return an array of attributes to fetch from nodes for this monitor.
		def self::node_properties
			return NODE_PROPERTIES
		end


		### Instantiate a monitor check and run it for the specified +nodes+.
		def self::run( nodes )
			return self.new.run( nodes )
		end


		### Create a new HTTP webservice monitor with the specified +options+. Valid options are:
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


		### Test HTTP connections for the specified +nodes+.
		def run( nodes )
			results = {}
			hydra = Typhoeus::Hydra.new( self.runner_settings )

			nodes.each do |identifier, node|
				self.log.debug "Making request for node %s" % [ identifier ]
				request = self.request_for_node( node )
				request.on_complete do |response|
					self.log.debug "Handling response for %s" % [ identifier ]
					results[ identifier ] =
						self.make_response_results( response, node['expected_status'] )
				end
				hydra.queue( request )
			end

			hydra.run

			return results
		end


		### Return a request object built to test the specified webservice +node+.
		def request_for_node( node_data )
			http_version = convert_http_version( node_data['http_version'] || DEFAULT_HTTP_VERSION )

			options = {
				method: node_data['http_method'] || DEFAULT_HTTP_METHOD,
				http_version: http_version,
				headers: self.make_headers_hash( node_data ),
				body: node_data['body'],
				timeout: self.timeout,
				connecttimeout: self.timeout / 2.0,
			}

			if ssl_opts = self.make_ssl_options( node_data['uri'], node_data )
				options.merge!( ssl_opts )
			end

			self.log.debug "Node options for %p are: %p" % [ node_data['uri'], options ]
			return Typhoeus::Request.new( node_data['uri'], options )
		end


		### Make a Hash of SSL options if any are specified.
		def make_ssl_options( uri, node_data )
			return nil unless uri.start_with?( 'https:' )

			self.log.debug "Extracting valid SSL options from the node's config: %p" %
				[ node_data['config'] ]
			ssl_attributes = SSL_ATTRIBUTES.each_with_object({}) do |(key, desc), opts|
				opts[ key ] = node_data[ 'config' ][ key.to_s ] if
					node_data['config']&.key?( key.to_s )
			end

			ssl_attributes[ :ssl_verifypeer ] ||= Arborist::Monitor::Webservice.ssl_verifypeer

			return ssl_attributes
		end


		### Extract header values from the node_data, combine them with the defaults,
		### and return them as a Hash.
		def make_headers_hash( node_data )
			headers = DEFAULT_HTTP_HEADERS.merge( node_data['http_headers'] || {} )
			if node_data['body']
				headers[ 'Content-type' ] ||= node_data['body_mimetype'] ||
					 'application/x-www-form-urlencoded'
			end

			return headers
		end


		### Return a Hash of options to pass to the request runner.
		def runner_settings
			return {
				max_concurrency: Arborist::Monitor::Webservice.max_concurrency,
			}
		end


		### Return a Hash of results appropriate for the specified +response+.
		def make_response_results( response, expected_status=200 )
			if response.code == expected_status
				return { webservice: self.success_results(response) }
			elsif response.timed_out?
				self.log.error "Request timed out."
				return { error: 'Request timed out.' }
			elsif response.code == 0
				self.log.error( response.return_message )
				return { error: response.return_message }
			else
				errmsg = "Got an unexpected %03d %s response; expected %03d." %
					[ response.code, response.status_message, expected_status ]
				self.log.error( errmsg )
				return { error: errmsg }
			end
		end


		### Return the information hash attached to webservice nodes for successful
		### responses.
		def success_results( response )
			return {
				http_version: response.http_version,
				status: response.code,
				status_message: response.status_message,
				headers: response.headers_hash,
				appconnect_time: response.appconnect_time,
				connect_time: response.connect_time,
				lookup_time: response.name_lookup_time,
				pretransfer_time: response.pretransfer_time,
				redirect_count: response.redirect_count,
				redirect_time: response.redirect_time,
				start_transfer_time: response.start_transfer_time,
				total_time: response.total_time,
			}
		end


		#######
		private
		#######

		### Convert a version string like `1.1` into the Symbol Typhoeus/Ethon expect
		### (e.g., `:httpv1_1`)
		def convert_http_version( version_string )
			return case version_string
				when '1.0'
					:httpv1_0
				when '1.1'
					:httpv1_1
				when '2.0'
					:httpv2_0
				else
					version_string.to_sym
				end
		end

	end # class HTTP


	# Arborist REST webservice monitor logic
	class REST < Arborist::Monitor::Webservice::HTTP
	end # class REST

end # class Arborist::Monitor::Webservice

