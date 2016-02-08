#!/usr/bin/ruby -*- ruby -*-

require 'configurability'
require 'loggability'
require 'pathname'
require 'bundler'

$LOAD_PATH.unshift( '../cozy-base/lib', 'lib' )

begin
	require 'cozy'
	require 'arborist/node/webservice'

	Loggability.level = :debug
	Loggability.format_with( :color )

	if Cozy::DEFAULT_CONFIG_FILE.exist?
		$stderr.puts 'Loading the default config'
		Cozy.load_config
	end

rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


