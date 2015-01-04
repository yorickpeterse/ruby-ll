require 'pathname'

require 'ast'
require 'ansi/code'

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
require_relative 'll/token'
require_relative 'll/parser_error'
require_relative 'll/compiler'
require_relative 'll/code_generator'
require_relative 'll/compiled_parser'
require_relative 'll/rule'
require_relative 'll/terminal'
require_relative 'll/message'
require_relative 'll/ast/node'
