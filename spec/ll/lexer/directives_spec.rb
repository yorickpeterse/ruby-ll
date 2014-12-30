require 'spec_helper'

describe LL::Lexer do
  context 'directives' do
    example 'lex the %name directive' do
      input = '%name Foo;'

      lex(input).should == [
        token(:T_NAME, '%name', source_line(input)),
        token(:T_IDENT, 'Foo', source_line(input, 1, 7)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 10))
      ]
    end

    example 'lex the %name directive preceded by spaces' do
      input = '  %name Foo;'

      lex(input).should == [
        token(:T_NAME, '%name', source_line(input, 1, 3)),
        token(:T_IDENT, 'Foo', source_line(input, 1, 9)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 12))
      ]
    end

    example 'lex the %name directive preceded by a newline' do
      input = "\n%name Foo;"

      lex(input).should == [
        token(:T_NAME, '%name', source_line(input, 2)),
        token(:T_IDENT, 'Foo', source_line(input, 2, 7)),
        token(:T_SEMICOLON, ';', source_line(input, 2, 10))
      ]
    end

    example 'lex the %name directive preceded by a newline and spaces' do
      input = "\n  %name Foo;"

      lex(input).should == [
        token(:T_NAME, '%name', source_line(input, 2, 3)),
        token(:T_IDENT, 'Foo', source_line(input, 2, 9)),
        token(:T_SEMICOLON, ';', source_line(input, 2, 12))
      ]
    end

    example 'lex the %tokens directive' do
      input = '%tokens A B C;'

      lex(input).should == [
        token(:T_TOKENS, '%tokens', source_line(input)),
        token(:T_IDENT, 'A', source_line(input, 1, 9)),
        token(:T_IDENT, 'B', source_line(input, 1, 11)),
        token(:T_IDENT, 'C', source_line(input, 1, 13)),
        token(:T_SEMICOLON, ';', source_line(input, 1, 14))
      ]
    end

    example 'lex the %inner directive' do
      input = <<-EOF.strip
%inner {
  foo
  bar
}
      EOF

      lex(input).should == [
        token(:T_INNER, '%inner', source_line(input)),
        token(:T_RUBY, "\n  foo\n  bar\n", source_line(input, 1))
      ]
    end

    example 'lex the %header directive' do
      input = <<-EOF.strip
%header {
  foo
  bar
}
      EOF

      lex(input).should == [
        token(:T_HEADER, '%header', source_line(input)),
        token(:T_RUBY, "\n  foo\n  bar\n", source_line(input, 1))
      ]
    end
  end
end
