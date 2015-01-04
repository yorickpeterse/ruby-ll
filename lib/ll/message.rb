module LL
  ##
  # A warning/error generated during the compilation of a grammar.
  #
  class Message
    attr_reader :type, :message, :source_line

    ##
    # @param [Symbol] type
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def initialize(type, message, source_line)
      @type        = type
      @message     = message
      @source_line = source_line
    end

    ##
    # @return [String]
    #
    def to_s
      file   = source_line.file
      line   = source_line.line
      column = source_line.column

      padding = ' ' * (column - 1)
      marker  = padding + '^'

      msg_line = "#{file}:#{line}:#{column}:#{type}: #{message}"

      return "#{msg_line}\n#{source_line.source}\n#{marker}"
    end
  end # Message
end # LL
