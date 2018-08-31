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

	# The version of HTTP to use in the request line
	DEFAULT_HTTP_VERSION = '2.0'

	# The headers to include with the request
	DEFAULT_HTTP_HEADERS = {
		'Connection' => 'close',
		'Accept' => '*/*',
		'User-Agent' => "Arborist-WebService/%s" % [ Arborist::Webservice::VERSION ],
	}.freeze

	# The SSL attributes that are settable
	SSL_ATTRIBUTES = {
		sslcert: "Client cert.",
		sslcerttype: "Client cert type.",
		sslkey: "Client key.",
		sslkeytype: "Client key type.",
		keypasswd: "Client key password.",
		ssl_enable_alpn: "Enable use of ALPN.",
		ssl_enable_npn: "Enable use of NPN.",
		sslengine: "Use identifier with SSL engine.",
		sslengine_default: "Default SSL engine.",
		ssl_falsestart: "Enable TLS False Start.",
		sslversion: "SSL version to use.",
		ssl_verifyhost: "Verify the host name in the SSL certificate.",
		ssl_verifypeer: "Verify the SSL certificate.",
		ssl_verifystatus: "Verify the SSL certificate's status.",
		cainfo: "CA cert bundle.",
		issuercert: "Issuer certificate.",
		capath: "Path to CA cert bundle.",
		crlfile: "Certificate Revocation List.",
		certinfo: "Extract certificate info.",
		pinnedpublickey: "Set pinned SSL public key .",
		random_file: "Provide source for entropy random data.",
		egdsocket: "Identify EGD socket for entropy.",
		ssl_cipher_list: "Ciphers to use.",
		tls13_ciphers: "TLS 1.3 cipher suites to use.",
		ssl_sessionid_cache: "Disable SSL session-id cache.",
		ssl_options: "Control SSL behavior.",
		krblevel: "Kerberos security level.",
		gssapi_delegation: "Disable GSS-API delegation.",
		proxy_sslcert: "Proxy client cert.",
		proxy_sslcerttype: "Proxy client cert type.",
		proxy_sslkey: "Proxy client key.",
		proxy_sslkeytype: "Proxy client key type.",
		proxy_keypasswd: "Proxy client key password.",
		proxy_sslversion: "Proxy SSL version to use.",
		proxy_ssl_verifyhost: "Verify the host name in the proxy SSL certificate.",
		proxy_ssl_verifypeer: "Verify the proxy SSL certificate.",
		proxy_cainfo: "Proxy CA cert bundle.",
		proxy_capath: "Path to proxy CA cert bundle.",
		proxy_crlfile: "Proxy Certificate Revocation List.",
		proxy_pinnedpublickey: "Set the proxy's pinned SSL public key.",
		proxy_ssl_cipher_list: "Proxy ciphers to use.",
		proxy_tls13_ciphers: "Proxy TLS 1.3 cipher suites to use.",
		proxy_ssl_options: "Control proxy SSL behavior.",
	}.freeze


end # module Arborist::Webservice::Constants
