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

    ##
    # @see [LL::Token#initialize]
    # @return [LL::Token]
    #
    def token(*args)
      return LL::Token.new(*args)
    end

    ##
    # @see [LL::AST::Node]
    # @param [Symbol] type
    # @param [Array] children
    #
    def s(type, *children)
      return LL::AST::Node.new(type, children)
    end
  end # ParsingHelpers
end # LL
