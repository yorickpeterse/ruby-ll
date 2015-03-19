require 'spec_helper'

describe LL::Lexer do
  describe 'operators' do
    it 'lexes an identifier followed by the + operator' do
      input = 'foo+'

      lex(input).should == [
        token(:T_IDENT, 'foo', source_line(input)),
        token(:T_PLUS, '+', source_line(input, 1, 4))
      ]
    end

    it 'lexes an identifier followed by the * operator' do
      input = 'foo*'

      lex(input).should == [
        token(:T_IDENT, 'foo', source_line(input)),
        token(:T_STAR, '*', source_line(input, 1, 4))
      ]
    end

    it 'lexes an identifier followed by the ? operator' do
      input = 'foo?'

      lex(input).should == [
        token(:T_IDENT, 'foo', source_line(input)),
        token(:T_QUESTION, '?', source_line(input, 1, 4))
      ]
    end
  end
end
