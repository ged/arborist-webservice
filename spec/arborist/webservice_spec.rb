#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'arborist/webservice'


describe Arborist::Webservice do

	it "has a version constant" do
		expect( described_class::VERSION ).to match( /^\d+(\.\d+){2}$/ )
	end


	it "can return a version string for itself" do
		expect( described_class.version_string ).
			to match( /Arborist::Webservice v\d+\.\d+\.\d+/ )
	end


	it "can return a version string with the build ID" do
		expect( described_class.version_string(include_build: true) ).
			to match( /Arborist::Webservice v\d+\.\d+\.\d+.*\(Revision: \w+\)/ )
	end

end

