desc 'Runs the tests'
task :test => [:generate] do
  sh 'rspec spec --order random'
end

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:"test-opal") do |_, task|
  Opal.use_gem 'ansi'
  Opal.append_path File.expand_path('../../lib', __FILE__)
  Opal.append_path File.expand_path('../../ext/pureruby', __FILE__)

  task.default_path = 'spec'
  task.pattern = 'spec/**/*_spec.{rb,opal}'
  task.runner = :node
  task.exclude_pattern = [] # "spec/**/*nokogiri*"
  ENV['SPEC_OPTS'] ||= "--format documentation --color"
end
