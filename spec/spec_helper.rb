require 'stringio'
require 'rspec'

if ENV['COVERAGE']
  require_relative 'support/simplecov'
end

require_relative '../lib/ll'
require_relative 'support/parsing'

RSpec.configure do |config|
  config.color = true

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.include LL::ParsingHelpers
end
