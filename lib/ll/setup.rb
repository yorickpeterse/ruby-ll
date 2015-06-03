require 'll/version'
require 'll/driver'
require 'll/driver_config'
require 'll/parser_error'
require 'll/configuration_compiler'
require 'libll'

#:nocov:
if RUBY_PLATFORM == 'java'
  org.libll.Libll.load(JRuby.runtime)
end
#:nocov:
