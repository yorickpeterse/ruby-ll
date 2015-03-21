require 'bundler'
require 'bundler/gem_tasks'
require 'digest/sha2'
require 'rake/clean'

if Gem.win_platform?
  task :devkit do
    begin
      require 'devkit'
    rescue LoadError
      warn 'Failed to load devkit, installation might fail'
    end
  end

  task :compile => [:devkit]
end

GEMSPEC = Gem::Specification.load('ruby-ll.gemspec')

if RUBY_PLATFORM == 'java'
  require 'rake/javaextensiontask'

  Rake::JavaExtensionTask.new('libll', GEMSPEC) do |task|
    task.ext_dir = 'ext/java'
  end
else
  require 'rake/extensiontask'

  Rake::ExtensionTask.new('libll', GEMSPEC) do |task|
    task.ext_dir = 'ext/c'
  end
end

CLEAN.include(
  'coverage',
  'yardoc',
  'lib/libll.*',
  'lib/ll/lexer.rb',
  'benchmark/parsers/racc/*.rb',
  'benchmark/parsers/ll/*.rb',
  'tmp'
)

Dir['./task/*.rake'].each do |task|
  import(task)
end

task :default => :test
