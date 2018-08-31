# -*- ruby -*-
#encoding: utf-8

require 'simplecov' if ENV['COVERAGE']

require 'rspec'

require 'loggability/spechelpers'
require 'arborist'
require 'arborist/mixins'
require 'arborist/webservice'


RSpec::Matchers.define( :match_criteria ) do |criteria|
	match do |node|
		criteria = Arborist::HashUtilities.stringify_keys( criteria )
		node.matches?( criteria )
	end
end


### Mock with RSpec
RSpec.configure do |config|
	config.run_all_when_everything_filtered = true
	config.filter_run :focus
	config.order = 'random'
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.include( Loggability::SpecHelpers )
end


