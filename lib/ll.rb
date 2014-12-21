require_relative 'll/version'
require_relative 'll/driver'

require_relative 'libll'

#:nocov:
if RUBY_PLATFORM == 'java'
  org.libll.Libll.load(JRuby.runtime)
end
#:nocov:

require_relative 'll/lexer'
require_relative 'll/source_line'
