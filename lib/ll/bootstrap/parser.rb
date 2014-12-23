module LL
  module Bootstrap
    ##
    # Hand-written LL(1) parser for parsing ruby-ll grammar files. This parser
    # is used to bootstrap ruby-ll and generate a parser based on its own
    # grammar file.
    #
    class Parser < Driver
      ##
      # The terminals/token names and their indexes.
      #
      # @return [Hash]
      #
      TOKENS = {

      }

      ##
      # The terminals/non-terminals of every rule, in reverse order.
      #
      # @return [Array]
      #
      RULES = [

      ]

      ##
      # The state transition table for every terminal.
      #
      # @return [Array]
      #
      TABLE = [

      ]

      ##
      # The available action names and their argument counts.
      #
      # @return [Array]
      #
      ACTIONS = [

      ]

      ##
      # @see [LL::Lexer#initialize]
      #
      def initialize(*args)
        super()

        @lexer = Lexer.new(*args)
      end
    end # Parser
  end # Bootstrap
end # LL
