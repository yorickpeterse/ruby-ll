require 'spec_helper'

describe LL::Lexer do
  describe 'using rules' do
    it 'lexes a rule containing only a single identifier' do
      input = 'x = y;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y', source_line(input, 1, 5)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 6))
      ]
    end

    it 'lexes a rule containing a single identifier with an underscore' do
      input = 'x = y_z;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y_z', source_line(input, 1, 5)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 8))
      ]
    end

    it 'lexes a rule using non-ASCII characters as the rule name' do
      input = '쿠키 = x;'

      lex(input).should == [
        token(:T_IDENT, '쿠키', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 4)),
        token(:T_IDENT, 'x', source_line(input, 1, 6)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 7))
      ]
    end

    it 'lexes a rule containing two identifiers' do
      input = 'x = y z;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y', source_line(input, 1, 5)),
        token(:T_IDENT, 'z', source_line(input, 1, 7)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 8))
      ]
    end

    it 'lexes a rule conaining two identifiers separated by a pipe' do
      input = 'x = y | z;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y', source_line(input, 1, 5)),
        token(:T_PIPE, '|', source_line(input, 1, 7)),
        token(:T_IDENT, 'z', source_line(input, 1, 9)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 10))
      ]
    end

    it 'lexes two rules containing a single identifier' do
      input = <<-EOF.strip
a = b | c;
b = x;
      EOF

      lex(input).should == [
        token(:T_IDENT, 'a', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'b', source_line(input, 1, 5)),
        token(:T_PIPE, '|', source_line(input, 1, 7)),
        token(:T_IDENT, 'c', source_line(input, 1, 9)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 10)),
        token(:T_IDENT, 'b', source_line(input, 2)),
        token(:T_EQUALS, '=', source_line(input, 2, 3)),
        token(:T_IDENT, 'x', source_line(input, 2, 5)),
        token(:T_SEMICOLON, ';', source_line(input, 2, 6))
      ]
    end

    it 'lexes a rule containing a named capture' do
      input = 'x = y:foo;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y', source_line(input, 1, 5)),
        token(:T_COLON, ':', source_line(input, 1, 6)),
        token(:T_IDENT, 'foo', source_line(input, 1, 7)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 10))
      ]
    end

    it 'lexes a rule containing an epsilon' do
      input = 'x = _;'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_EPSILON, '_', source_line(input, 1, 5)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 6))
      ]
    end

    it 'lexes a rule followed by a block of Ruby code' do
      input = 'x = y { 10 };'

      lex(input).should == [
        token(:T_IDENT, 'x', source_line(input)),
        token(:T_EQUALS, '=', source_line(input, 1, 3)),
        token(:T_IDENT, 'y', source_line(input, 1, 5)),
        token(:T_RUBY, ' 10 ', source_line(input, 1, 8)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 13))
      ]
    end
  end
end
