# -*- ruby -*-
#encoding: utf-8

require 'httpclient'
require 'arborist/webservice' unless defined?( Arborist::Webservice )

module Arborist::Webservice::MonkeyPatches

	refine HTTPClient::Connection do

		### Return +true+ if the connection has a queued response but is waiting on
		### streaming I/O before it can complete.
		###
		### This is a hack to work around https://github.com/nahi/httpclient/issues/70
		def streaming?
			return !@queue.empty? && @async_thread.status == 'sleep'
		end

	end # refine HTTPClient::Connection

end # module Arborist::Webservice::MonkeyPatches

