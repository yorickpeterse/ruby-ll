require_relative 'version'
require_relative 'driver'
require_relative 'driver_config'
require_relative 'parser_error'
require_relative 'configuration_compiler'
require_relative '../libll'

#:nocov:
if RUBY_PLATFORM == 'java'
  org.libll.Libll.load(JRuby.runtime)
end
#:nocov:
