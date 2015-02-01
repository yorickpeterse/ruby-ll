module LL
  ##
  # Parser driver for generated (or hand written) parsers.
  #
  class Driver
    ##
    # Error method that is called when no rule was found for a given terminal.
    #
    # @param [Fixnum] token_id The ID/index of the token/terminal.
    #
    def missing_rule_error(token_id)
      token_name = self.class::CONFIG.terminals.invert[token_id]

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
      inverted = self.class::CONFIG.terminals.invert
      expected = inverted[expected_id]
      got      = inverted[got_id]

      raise ParserError, "Invalid input token #{got}, expected #{expected}"
    end
  end # Driver
end # LL
