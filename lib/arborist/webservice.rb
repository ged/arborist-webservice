# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'arborist'


# A collection of HTTP tools for the Arborist monitoring toolkit.
module Arborist::Webservice
	extend Loggability

	# Loggability API -- set up a log host for this library
	log_as :arborist_webservice


	# Package version
	VERSION = '0.0.1'

	# Version control revision
	REVISION = %q$Revision$


	### Return the name of the library with the version, and optionally the build ID if
	### +include_build+ is true.
	def self::version_string( include_build: false )
		str = "%p v%s" % [ self, VERSION ]
		str << ' (' << REVISION.strip << ')' if include_build
		return str
	end


	require 'arborist/monitor/webservice'
	require 'arborist/node/webservice'

	autoload :Constants, 'arborist/webservice/constants'

end # module Arborist::Webservice

