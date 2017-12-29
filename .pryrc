#!/usr/bin/ruby -*- ruby -*-

$LOAD_PATH.unshift( '../Arborist/lib', 'lib' )

begin
	require 'arborist/node/webservice'
rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


