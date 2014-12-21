module LL
  module ParsingHelpers
    ##
    # @param [String] input
    # @return [Array]
    #
    def lex(input)
      return LL::Lexer.new(input).lex
    end

    ##
    # @see [LL::SourceLine#initialize]
    # @return [LL::SourceLine]
    #
    def source_line(*args)
      return LL::SourceLine.new(*args)
    end
  end # ParsingHelpers
end # LL
