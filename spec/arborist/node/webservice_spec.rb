#!/usr/bin/env rspec -cfd
#encoding: utf-8

require_relative '../../spec_helper'

require 'rspec'
require 'arborist/node/webservice'

describe Arborist::Node::Webservice do

	it "can match on URI"
	it "can match on HTTP method"
	it "can match on request body"
	it "can match on request body media type"

	it "includes the URI in the operational attributes"
	it "includes the HTTP method in the operational attributes"
	it "includes the request body in the operational attributes"
	it "includes the request body media type in the operational attributes"

	it "provides a DSL declaration to disable SSL verification"

end

