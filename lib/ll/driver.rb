module LL
  ##
  # Parser driver for generated (or hand written) parsers.
  #
  class Driver
    ##
    # Error method that is called when no rule was found for a table index.
    #
    # @param [Fixnum] type
    # @param [Fixnum] value
    #
    def stack_input_error(type, value)
      label = ConfigurationCompiler::TYPES.invert[type]

      if label
        raise ParserError, "Unexpected #{label} #{value.inspect} on the stack"
      else
        raise(
          ParserError,
          "Unknown stack input type #{type.inspect} with value #{value.inspect}"
        )
      end
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
