# -*- ruby -*-
#encoding: utf-8

require 'thread'
require 'httpclient'

require 'arborist'
require 'arborist/webservice'
require 'arborist/mixins'
require 'arborist/monitor' unless defined?( Arborist::Monitor )
require 'arborist/webservice/monkeypatches'

# Hack around HTTPClient async problems
using Arborist::Webservice::MonkeyPatches


# A web-service monitor type for Arborist
module Arborist::Monitor::Webservice

	using Arborist::TimeRefinements



	# Arborist HTML web service monitor logic
	class HTML
		extend Loggability
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
		def initialize( options=DEFAULT_OPTIONS )
			options = DEFAULT_OPTIONS.merge( options || {} )

			options.each do |name, value|
				self.public_send( "#{name}=", value )
			end

			agent = "%p/%s via %s" %
				[ self.class, Arborist::Webservice::VERSION, HTTPClient::DEFAULT_AGENT_NAME ]
			@client = HTTPClient.new( agent_name: agent )
		end


		######
		public
		######

		# The timeout for connecting, in seconds.
		attr_accessor :timeout

		# The HTTPClient object to use for HTTP
		attr_accessor :client


		### Return a clone of this object with its timeout set to +new_timeout+.
		def with_timeout( new_timeout )
			copy = self.clone
			copy.timeout = new_timeout
			return copy
		end


		### Run the HTML check for each of the specified Hash of +nodes+ and return a Hash of
		### updates for them based on trying to connect to them.
		def run( nodes )
			self.log.debug "Got %d nodes to check with %p" % [ nodes.length, self ]

			requests = self.make_requests( nodes )
			return self.wait_for_responses( nodes, requests )
		end


		### Create async HTTP requests for each of the given +nodes+ and return them as
		### a Hash of requests and node identifiers.
		def make_requests( nodes )
			requests = {}

			nodes.each do |identifier, node_data|
				uri           = node_data['uri']
				http_method   = node_data['http_method'] || 'HEAD'
				body          = node_data['body']
				body_mimetype = node_data['body_mimetype']

				header = {
					'Connection' => 'close'
				}

				conn = case http_method
					when 'GET'
						self.client.get_async( uri, header: header )
					when 'HEAD'
						self.client.head_async( uri, header: header )
					when 'POST'
						header['Content-type'] = body_mimetype
						self.client.post_async( uri, body: body, header: header )
					when 'PUT'
						header['Content-type'] = body_mimetype
						self.client.put_async( uri, body: body, header: header )
					when 'DELETE'
						self.client.delete_async( uri, header: header )
					else
						self.log.error "Skipping unsupported HTTP method %p for %s" %
							[ http_method, identifier ]
						next
					end

				requests[ conn ] = identifier
			end

			return requests
		end


		### Fetch the response from each of the specified +requests+ and return a Hash
		### of results keyed by the identifier of the node the request was made for.
		def wait_for_responses( nodes, requests )
			results = {}
			start = Time.now
			timeout_at = Time.now + self.timeout

			until requests.empty? || timeout_at.past?
				responses = self.extract_finished_responses( nodes, requests )
				results.merge!( responses )
			end

			# The rest are timeouts
			if !requests.empty?
				errors = self.timeout_requests( requests )
				results.merge!( errors )
			end

			self.client.reset_all

			return results
		end


		### Look for +requests+ that are finished and remove them. Modifies +requests+
		### in place and returns a Hash of results based on responses.
		def extract_finished_responses( nodes, requests )
			results = {}

			requests.keys.each do |conn|
				begin
					# This uses a hack from Arborist::Webservice::MonkeyPatches to detect when a
					# response body is too big to fit in the read buffer, so is never #finished?.
					next unless conn.finished? || conn.streaming?

					identifier = requests.delete( conn )
					message = conn.pop
					expected_status = nodes[ identifier ]['expected_status'] || 200

					if message.status_code == expected_status.to_i
						results[ identifier ] = {
							status: message.status_code,
							http_version: message.http_version,
							http_server: message.headers['server'],
							http_csp: message.headers['content-security-policy'],
						}
					else
						results[ identifier ] = {
							error: "#{message.status_code} response",
							status: message.status_code,
							http_version: message.http_version,
						}
					end

					if conn.async_thread.alive?
						conn.async_thread.kill
					else
						conn.join
					end
				rescue => err
					identifier ||= requests.delete( conn ) or
						raise "Couldn't find identifier for request %p" % [ conn ]
					results[ identifier ] = { error: err.message }
					conn.join
				end
			end

			return results
		end


		### Cancel each of the given +requests+ and return a Hash of results.
		def timeout_requests( requests )
			results = {}
			requests.each do |conn, identifier|
				conn.async_thread.kill
				results[ identifier ] = {
					error: "Request timeout after %ds." % [ self.timeout ]
				}
			end

			return results
		end

	end # class HTML


	# Arborist REST webservice monitor logic
	class REST < Arborist::Monitor::Webservice::HTML
	end # class REST

end # class Arborist::Monitor::Webservice

