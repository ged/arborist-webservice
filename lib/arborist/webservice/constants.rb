# -*- ruby -*-
# frozen_string_literal: true

require 'arborist/webservice' unless defined?( Arborist::Webservice )


module Arborist::Webservice::Constants

	# The default HTTP verb to use for monitoring requests
	DEFAULT_HTTP_METHOD = 'HEAD'.freeze

	# The default HTTP status code to expect from responses
	DEFAULT_EXPECTED_STATUS = 200

	# The default Content-type to use for requests with a body
	DEFAULT_BODY_MIMETYPE = 'text/plain'.freeze

	# The headers to include with the request
	DEFAULT_HTTP_HEADERS = {
		'Connection' => 'close',
		'Accept' => '*/*',
		'User-Agent' => "Arborist-WebService/%s" % [ Arborist::Webservice::VERSION ],
	}.freeze

	# The HTTP verb to use in the request line by default
	DEFAULT_HTTP_METHOD = 'GET'

	# The version of HTTP to use in the request line
	DEFAULT_HTTP_VERSION = '1.0'

	# The SSL attributes that are settable
	SSL_ATTRIBUTES = {
		ssl_ca_file: :ca_file,
		ssl_ca_path: :ca_path,
		ssl_cert: :cert,
		ssl_cert_store: :cert_store,
		ssl_ciphers: :ciphers,
		ssl_key: :key,
		ssl_timeout: :ssl_timeout,
		ssl_version: :ssl_version,
		ssl_min_version: :min_version,
		ssl_max_version: :max_version,
		ssl_verify_callback: :verify_callback,
		ssl_verify_depth: :verify_depth,
		ssl_verify_mode: :verify_mode,
	}.freeze


end # module Arborist::Webservice::Constants
