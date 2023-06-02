require 'll/version'
require 'll/driver'
require 'll/driver_config'
require 'll/parser_error'
require 'll/configuration_compiler'

if RUBY_PLATFORM == 'opal'
  require 'll/native/driver'
  require 'll/native/driver_config'
elsif ENV['RUBYLL_PURERUBY']
  require_relative '../../ext/pureruby/ll/native/driver'
  require_relative '../../ext/pureruby/ll/native/driver_config'
else
  require 'libll'
end

#:nocov:
if RUBY_PLATFORM == 'java'
  org.libll.Libll.load(JRuby.runtime)
end
#:nocov:
