require 'spec_helper'

describe LL::Lexer do
  context 'rules' do
    example 'lex a rule containing only a single identifier' do
      input = 'x : y'

      lex(input).should == [
        [:T_IDENT, 'x', source_line(input)],
        [:T_COLON, ':', source_line(input, 1, 3)],
        [:T_IDENT, 'y', source_line(input, 1, 5)]
      ]
    end

    example 'lex a rule containing two identifiers' do
      input = 'x : y z'

      lex(input).should == [
        [:T_IDENT, 'x', source_line(input)],
        [:T_COLON, ':', source_line(input, 1, 3)],
        [:T_IDENT, 'y', source_line(input, 1, 5)],
        [:T_IDENT, 'z', source_line(input, 1, 7)]
      ]
    end

    example 'lex a rule conaining two identifiers separated by a pipe' do
      input = 'x : y | z'

      lex(input).should == [
        [:T_IDENT, 'x', source_line(input)],
        [:T_COLON, ':', source_line(input, 1, 3)],
        [:T_IDENT, 'y', source_line(input, 1, 5)],
        [:T_PIPE, '|', source_line(input, 1, 7)],
        [:T_IDENT, 'z', source_line(input, 1, 9)]
      ]
    end

    example 'lex two rules containing a single identifier' do
      input = <<-EOF.strip
a : b | c
b : x
      EOF

      lex(input).should == [
        [:T_IDENT, 'a', source_line(input)],
        [:T_COLON, ':', source_line(input, 1, 3)],
        [:T_IDENT, 'b', source_line(input, 1, 5)],
        [:T_PIPE, '|', source_line(input, 1, 7)],
        [:T_IDENT, 'c', source_line(input, 1, 9)],
        [:T_IDENT, 'b', source_line(input, 2)],
        [:T_COLON, ':', source_line(input, 2, 3)],
        [:T_IDENT, 'x', source_line(input, 2, 5)],
      ]
    end
  end
end
