#!/usr/bin/env rspec -cfd
#encoding: utf-8

require_relative '../../spec_helper'

require 'rspec'
require 'arborist/node/host'
require 'arborist/node/webservice'

describe Arborist::Node::Webservice do

	let( :host_node ) do
		Arborist::Host 'testhost' do
			address '192.168.66.12'
			address '10.2.12.68'
			hostname 'example.com'
		end
	end

	let( :node ) { host_node.webservice('api', 'https://example.com/api/v1') }
	let( :getonly_node ) do
		host_node.webservice( 'repo-api', 'https://repo.example.com/' ) do
			http_method 'GET'
		end
	end
	let( :http10_node ) do
		host_node.webservice( 'archive-site', 'http://archive.example.com/' ) do
			http_version '1.0'
		end
	end


	it "can match on URI" do
		expect( node ).to match_criteria( uri: 'https://example.com/api/v1' )
		expect( node ).to_not match_criteria( uri: 'https://example.com/api/v2' )
		expect( node ).to_not match_criteria( uri: 'https://bitter.com/api/v1' )
		expect( node ).to_not match_criteria( uri: 'http://example.com/api/v1' )
	end


	it "can match on HTTP method" do
		expect( node ).to match_criteria( http_method: 'HEAD' )
		expect( node ).to_not match_criteria( http_method: 'GET' )
		expect( getonly_node ).to match_criteria( http_method: 'GET' )
		expect( getonly_node ).to_not match_criteria( http_method: 'HEAD' )
	end


	it "can match on HTTP version" do
		expect( node ).to match_criteria( http_version: '2.0' )
		expect( node ).to_not match_criteria( http_version: '1.0' )
		expect( http10_node ).to match_criteria( http_version: '1.0' )
		expect( http10_node ).to_not match_criteria( http_version: '1.1' )
	end


	it "includes the URI in the operational attributes" do
		expect( node.operational_values ).to include( uri: node.uri )
	end


	it "includes the HTTP method in the operational attributes" do
		expect( node.operational_values ).to include( http_method: node.http_method )
	end


	it "allows shorthand URI syntax for implicit host" do
		node = host_node.webservice( 'djinn', 'http:///' )
		expect( node.uri ).to eq( 'http://192.168.66.12/' )
	end


	it "allows shorthand URI syntax with a port for implicit host" do
		node = host_node.webservice( 'djinn', 'http://:8080/' )
		expect( node.uri ).to eq( 'http://192.168.66.12:8080/' )
	end


end

