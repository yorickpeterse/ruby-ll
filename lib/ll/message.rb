module LL
  ##
  # A warning/error generated during the compilation of a grammar.
  #
  class Message
    attr_reader :type, :message, :source_line

    ##
    # The colours to use for the various message types.
    #
    # @return [Hash]
    #
    COLORS = {
      :error   => :red,
      :warning => :yellow
    }

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
      padding = ' ' * (column - 1)
      marker  = padding + ANSI.bold(ANSI.magenta('^'))

      location   = ANSI.bold(ANSI.white("#{relative_path}:#{line}:#{column}"))
      type_label = ANSI.bold(ANSI.send(COLORS[type], type.to_s))

      msg_line = "#{location}:#{type_label}: #{message}"

      return "#{msg_line}\n#{source_line.source}\n#{marker}"
    end

    ##
    # @return [String]
    #
    def relative_path
      from = Pathname.new(source_line.file)
      to   = Pathname.new(Dir.pwd)

      return from.relative_path_from(to).to_s
    end

    ##
    # @return [Fixnum]
    #
    def line
      return source_line.line
    end

    ##
    # @return [Fixnum]
    #
    def column
      return source_line.column
    end
  end # Message
end # LL
