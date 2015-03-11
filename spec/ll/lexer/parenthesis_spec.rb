require 'spec_helper'

describe LL::Lexer do
  describe 'parenthesis' do
    it 'lexes a rule containing parenthesis' do
      input = 'A = (B);'

      lex(input).should == [
        token(:T_IDENT, 'A', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_LPAREN, '(', source_line(input, 1, 5)),
        token(:T_IDENT, 'B', source_line(input, 1, 6)),
        token(:T_RPAREN, ')', source_line(input, 1, 7)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 8))
      ]
    end
  end
end
