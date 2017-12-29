#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'arborist/webservice'


describe Arborist::Monitor::Webservice do

	using Arborist::TimeRefinements


	describe Arborist::Monitor::Webservice::HTML do

		let( :monitor ) { described_class.new }
		let( :host_node ) do
			Arborist::Node.create( :host, 'webserver' ) do
				description "Test host node with a few web services"
				address '10.2.18.64'
				tags :testing
			end
		end

		let( :webservice_node1 ) { host_node.webservice('marketing', 'https://www.acme.com/') }
		let( :webservice_node2 ) { host_node.webservice('store', 'https://store.acme.com/') }
		let( :webservice_node3 ) { host_node.webservice('support', 'https://int.support.acme.com/') }

		let( :nodes ) {[ webservice_node1, webservice_node2, webservice_node3 ]}
		let( :nodes_hash ) do
			nodes.each_with_object({}) do |node, accum|
				accum[ node.identifier ] = node.fetch_values
			end
		end


		it "is created with a default timeout" do
			expect( monitor.timeout ).to be_an( Integer )
		end


		it "can clone itself with a new timeout" do
			new_monitor = monitor.with_timeout( 2.minutes )
			expect( new_monitor ).to_not equal( monitor )
			expect( new_monitor.timeout ).to eq( 2.minutes )
		end


		it "runs against a collection of nodes and updates the statuses of each one" do
			monitor.client = instance_double( HTTPClient )

			msg1 = instance_double( HTTP::Message, ok?: true, status_code: 200, http_version: '1.1' )
			conn1 = instance_double( HTTPClient::Connection, finished?: true, pop: msg1 )
			msg2 = instance_double( HTTP::Message, ok?: true, status_code: 200, http_version: '1.1' )
			conn2 = instance_double( HTTPClient::Connection, finished?: true, pop: msg2 )
			msg3 = instance_double( HTTP::Message, ok?: true, status_code: 200, http_version: '1.1' )
			conn3 = instance_double( HTTPClient::Connection, finished?: true, pop: msg3 )

			expect( monitor.client ).to receive( :head_async ).with( webservice_node1.uri.to_s ).
				and_return( conn1 )
			expect( monitor.client ).to receive( :head_async ).with( webservice_node2.uri.to_s ).
				and_return( conn2 )
			expect( monitor.client ).to receive( :head_async ).with( webservice_node3.uri.to_s ).
				and_return( conn3 )

			result = monitor.run( nodes_hash )

			expect( result ).to be_a( Hash )
			expect( result.keys ).to contain_exactly( *nodes.map(&:identifier) )
		end


		it "sets an error for error response statuses" do
			monitor.client = instance_double( HTTPClient )

			msg1 = instance_double( HTTP::Message, ok?: true, status_code: 200, http_version: '1.1' )
			conn1 = instance_double( HTTPClient::Connection, finished?: true, pop: msg1 )
			msg2 = instance_double( HTTP::Message, ok?: true, status_code: 200, http_version: '1.1' )
			conn2 = instance_double( HTTPClient::Connection, finished?: true, pop: msg2 )

			msg3 = instance_double( HTTP::Message, ok?: false, status_code: 500, http_version: '1.1' )
			conn3 = instance_double( HTTPClient::Connection, finished?: true, pop: msg3 )

			expect( monitor.client ).to receive( :head_async ).with( webservice_node1.uri.to_s ).
				and_return( conn1 )
			expect( monitor.client ).to receive( :head_async ).with( webservice_node2.uri.to_s ).
				and_return( conn2 )
			expect( monitor.client ).to receive( :head_async ).with( webservice_node3.uri.to_s ).
				and_return( conn3 )

			result = monitor.run( nodes_hash )

			expect( result[webservice_node3.identifier] ).to include( error: '500 response' )
		end

	end


	describe "REST monitor logic"

end

