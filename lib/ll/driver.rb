module LL
  ##
  # Parser driver for generated (or hand written) parsers.
  #
  class Driver
    ##
    # Sets up the initial state of the parser.
    #
    def setup
      # Since every driver needs these variables we'll set these up ourselves.
      # Since these constants are not defined in the Driver class itself we have
      # to use `self.class::XXX` here.
      @tokens_hash   = self.class::TOKENS
      @rules_table   = self.class::RULES
      @state_table   = self.class::TABLE
      @actions_table = self.class::ACTIONS
    end

    ##
    # Error method that is called when no rule was found for a given terminal.
    #
    # @param [Fixnum] token_id The ID/index of the token/terminal.
    #
    def missing_rule_error(token_id)
      token_name = @tokens_hash.invert[token_id]

      raise ParserError, "No rule was found for token #{token_name}"
    end

    ##
    # Error method that is called when an invalid token was specified as the
    # input.
    #
    # @param [Fixnum] got_id The ID of the received token.
    # @param [Fixnum] expected_id The ID of the expected token.
    #
    def invalid_token_error(got_id, expected_id)
      inverted = @tokens_hash.invert
      expected = inverted[expected_id]
      got      = inverted[got_id]

      raise ParserError, "Invalid input token #{got}, expected #{expected}"
    end
  end # Driver
end # LL
