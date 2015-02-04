module LL
  ##
  # Parser driver for generated (or hand written) parsers.
  #
  class Driver
    ##
    # Error method that is called when no rule was found for a table index.
    #
    # @param [Fixnum] stack_value
    # @param [Array] token
    #
    def stack_input_error(stack_value, token)
      type = token[0].inspect

      raise ParserError, "Unexpected rule #{stack_value} for #{type}"
    end

    ##
    # Error method that is called when an invalid token was specified as the
    # input.
    #
    # @param [Fixnum] got_id The ID of the received token.
    # @param [Fixnum] expected_id The ID of the expected token.
    #
    def invalid_token_error(got_id, expected_id)
      terminals = self.class::CONFIG.terminals
      expected  = terminals[expected_id]
      got       = terminals[got_id]

      raise ParserError, "Invalid input token #{got}, expected #{expected}"
    end
  end # Driver
end # LL
