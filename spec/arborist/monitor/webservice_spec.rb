#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'typhoeus'
require 'arborist/webservice'


describe Arborist::Monitor::Webservice do

	using Arborist::TimeRefinements

	before( :each ) do
		Typhoeus::Expectation.clear
	end
	after( :each ) do
		Typhoeus::Expectation.clear
	end


	describe Arborist::Monitor::Webservice::HTTP do

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
			expect( monitor.timeout ).to be_an( Numeric )
		end


		it "can clone itself with a new timeout" do
			new_monitor = monitor.with_timeout( 2.minutes )
			expect( new_monitor ).to_not equal( monitor )
			expect( new_monitor.timeout ).to eq( 2.minutes )
		end


		it "runs against a collection of nodes and updates the statuses of each one" do
			Typhoeus.stub( /acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			result = monitor.run( nodes_hash )

			expect( result ).to be_a( Hash )
			expect( result.keys ).to contain_exactly( *nodes.map(&:identifier) )
		end


		it "sets an error for HTTP error response statuses" do
			Typhoeus.stub( /support\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 500, status_message: 'Server Error' )
			end
			Typhoeus.stub( /(www|store)\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			result = monitor.run( nodes_hash )

			expect( result[webservice_node3.identifier] ).to include( error: '500 Server Error' )
		end


		it "sets a human-readable error message for lower-layer error response statuses" do
			Typhoeus.stub( /store\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 0, return_code: :couldnt_connect )
			end
			Typhoeus.stub( /(www|support)\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			result = monitor.run( nodes_hash )

			expect( result[webservice_node2.identifier] ).to include( error: "Couldn't connect to server" )
		end


		it "sets an error for timeouts" do
			Typhoeus.stub( /store\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 0, return_code: :operation_timedout )
			end
			Typhoeus.stub( /(www|support)\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			result = monitor.run( nodes_hash )

			expect( result[webservice_node2.identifier] ).to include( error: 'Request timed out.' )
		end


		it "doesn't error if HTTP error response status matches the expected status" do
			Typhoeus.stub( /store\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 401, status_message: 'Access denied' )
			end
			Typhoeus.stub( /(www|support)\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			webservice_node2.expected_status( 401 )
			result = monitor.run( nodes_hash )

			expect( result[webservice_node2.identifier] ).to_not include( :error )
		end


		it "posts with the provided body if one is set" do
			Typhoeus.stub( /support\.acme/i ).and_return do |req|
				expect( req.options[:method] ).to eq( 'POST' )
				expect( req.options[:body] ).to eq( '[1, 2, 3, 4]' )
				expect( req.options[:headers] ).to include( 'Content-type' => 'application/json' )
				Typhoeus::Response.new( code: 201, status_message: 'Object created' )
			end
			Typhoeus.stub( /(www|store)\.acme/i ).and_return do |req|
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			webservice_node3.http_method( 'POST' )
			webservice_node3.body( '[1, 2, 3, 4]' )
			webservice_node3.body_mimetype( 'application/json' )
			webservice_node3.expected_status( 201 )

			result = monitor.run( nodes_hash )

			expect( result.keys ).to contain_exactly( *nodes.map(&:identifier) )
		end


		it "uses valid entries from the node's config as SSL configuration" do
			Typhoeus.stub( /acme/i ).and_return do |req|
				expect( req.options[:ssl_verifypeer] ).to eq( 0 )
				Typhoeus::Response.new( code: 200, body: "OK" )
			end

			nodes.each do |node|
				node.config( ssl_verifypeer: 0 )
			end

			result = monitor.run( nodes_hash )

			expect( result ).to be_a( Hash )
			expect( result.keys ).to contain_exactly( *nodes.map(&:identifier) )
		end

	end


	describe "REST monitor logic"

end

