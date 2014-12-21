require 'simplecov'

SimpleCov.configure do
  root         File.expand_path('../../../', __FILE__)
  command_name 'rspec'
  project_name 'ruby-ll'

  add_filter 'spec'
  add_filter 'lib/ll/version'
end

SimpleCov.start
