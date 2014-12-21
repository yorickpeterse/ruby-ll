%%machine ll_lexer; # %

module LL
  ##
  # Ragel lexer for LL grammar files.
  #
  class Lexer
    %% write data;

    # % fix highlight

    ##
    # @param [String] data The data to lex.
    # @param [String] file The name of the input file.
    #
    def initialize(data, file = '(ruby)')
      @data = data
      @file = file

      reset
    end

    ##
    # Gathers all the tokens for the input and returns them as an Array.
    #
    # @see [#advance]
    # @return [Array]
    #
    def lex
      tokens = []

      advance do |type, value, source_line|
        tokens << [type, value, source_line]
      end

      return tokens
    end

    ##
    # Resets the internal state of the lexer.
    #
    def reset
      @block  = nil
      @line   = 1
      @column = 1
    end

    ##
    # Advances through the input and generates the corresponding tokens. Each
    # token is yielded to the supplied block.
    #
    # Each token is an Array in the following format:
    #
    #     [TYPE, VALUE]
    #
    # The type is a symbol, the value is either nil or a String.
    #
    # This method stores the supplied block in `@block` and resets it after
    # the lexer loop has finished.
    #
    # @see [#add_token]
    #
    def advance(&block)
      @block = block

      data = @data # saves ivar lookups while lexing.
      ts   = nil
      te   = nil
      cs   = self.class.ll_lexer_start
      act  = 0
      eof  = @data.bytesize
      p    = 0
      pe   = eof

      mark        = 0
      brace_count = 0
      start_line  = 0

      _ll_lexer_eof_trans          = self.class.send(:_ll_lexer_eof_trans)
      _ll_lexer_from_state_actions = self.class.send(:_ll_lexer_from_state_actions)
      _ll_lexer_index_offsets      = self.class.send(:_ll_lexer_index_offsets)
      _ll_lexer_indicies           = self.class.send(:_ll_lexer_indicies)
      _ll_lexer_key_spans          = self.class.send(:_ll_lexer_key_spans)
      _ll_lexer_to_state_actions   = self.class.send(:_ll_lexer_to_state_actions)
      _ll_lexer_trans_actions      = self.class.send(:_ll_lexer_trans_actions)
      _ll_lexer_trans_keys         = self.class.send(:_ll_lexer_trans_keys)
      _ll_lexer_trans_targs        = self.class.send(:_ll_lexer_trans_targs)

      %% write exec;

      # % fix highlight
    ensure
      reset
    end

    private

    ##
    # Emits a token of which the value is based on the supplied start/stop
    # position.
    #
    # @param [Symbol] type The token type.
    # @param [Fixnum] start
    # @param [Fixnum] stop
    # @param [Fixnum] line
    #
    # @see [#text]
    # @see [#add_token]
    #
    def emit(type, start, stop, line = @line)
      value = slice_input(start, stop)

      add_token(type, value, line)
    end

    ##
    # Returns the text between the specified start and stop position.
    #
    # @param [Fixnum] start
    # @param [Fixnum] stop
    # @return [String]
    #
    def slice_input(start, stop)
      return @data.byteslice(start, stop - start)
    end

    ##
    # Yields a new token to the supplied block.
    #
    # @param [Symbol] type The token type.
    # @param [String] value The token value.
    # @param [Fixnum] line
    #
    # @yieldparam [Symbol] type
    # @yieldparam [String|NilClass] value
    # @yieldparam [LL::SourceLine] source_line
    #
    def add_token(type, value, line = @line)
      source_line = SourceLine.new(@data, line, @column, @file)
      @column    += value.length

      @block.call(type, value, source_line)
    end

    %%{
      getkey (data.getbyte(p) || 0);

      newline    = '\n';
      whitespace = [\t ];

      action increment_line {
        @line  += 1
        @column = 1
      }

      action increment_column {
        @column += 1
      }

      # Identifiers
      #
      # Identifiers are similar to Ruby identifiers: they must start with a
      # letter or underscore and can be followed by any letter, number or an
      # underscore

      identifier = [a-zA-Z_]+ [a-zA-Z_0-9]*;

      action emit_identifier {
        emit(:T_IDENT, ts, te)
      }

      # Comments
      #
      # Comments start with a # and end at the end of a line, just like Ruby
      # comments.

      comment = '#' ^(newline)*;

      # Ruby Blocks
      #
      # Blocks of Ruby code that can be used as actions, inner blocks, etc. This
      # is handled by counting open/closing curly braces and bailing out when
      # all of them are balanced out.

      ruby_body := |*
        newline $increment_line;

        '{' => { brace_count += 1 };

        '}' => {
          if brace_count == 1
            emit(:T_RUBY, mark, ts, start_line)

            mark        = 0
            brace_count = 0
            start_line  = 0

            fnext main;
          else
            brace_count -= 1
          end
        };

        any;
      *|;

      main := |*
        newline $increment_line;
        whitespace $increment_column;

        comment;

        '%name'     => { emit(:T_NAME, ts, te) };
        '%tokens'   => { emit(:T_TOKENS, ts, te) };
        '%left'     => { emit(:T_LEFT, ts, te) };
        '%right'    => { emit(:T_RIGHT, ts, te) };
        '%inner'    => { emit(:T_INNER, ts, te) };
        '%header'   => { emit(:T_HEADER, ts, te) };
        identifier  => emit_identifier;

        ':'   => { emit(:T_COLON, ts, te) };
        '|'   => { emit(:T_PIPE, ts, te) };
        '*'   => { emit(:T_STAR, ts, te) };
        '+'   => { emit(:T_PLUS, ts, te) };
        '?'   => { emit(:T_QUESTION, ts, te) };
        '('   => { emit(:T_LPAREN, ts, te) };
        ')'   => { emit(:T_RPAREN, ts, te) };
        '...' => { emit(:T_EPSILON, ts, te) };

        '{' => {
          mark        = ts + 1
          brace_count = 1
          start_line  = @line

          fnext ruby_body;
        };
      *|;
    }%%
  end # Lexer
end # Oga
