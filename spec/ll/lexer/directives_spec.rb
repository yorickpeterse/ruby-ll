require 'spec_helper'

describe LL::Lexer do
  context 'directives' do
    example 'lex the %name directive' do
      input = '%name Foo'

      lex(input).should == [
        [:T_NAME, '%name', source_line(input)],
        [:T_IDENT, 'Foo', source_line(input, 1, 7)]
      ]
    end

    example 'lex the %name directive preceded by spaces' do
      input = '  %name Foo'

      lex(input).should == [
        [:T_NAME, '%name', source_line(input, 1, 3)],
        [:T_IDENT, 'Foo', source_line(input, 1, 9)]
      ]
    end

    example 'lex the %name directive preceded by a newline' do
      input = "\n%name Foo"

      lex(input).should == [
        [:T_NAME, '%name', source_line(input, 2)],
        [:T_IDENT, 'Foo', source_line(input, 2, 7)]
      ]
    end

    example 'lex the %name directive preceded by a newline and spaces' do
      input = "\n  %name Foo"

      lex(input).should == [
        [:T_NAME, '%name', source_line(input, 2, 3)],
        [:T_IDENT, 'Foo', source_line(input, 2, 9)]
      ]
    end

    example 'lex the %tokens directive' do
      input = '%tokens A B C'

      lex(input).should == [
        [:T_TOKENS, '%tokens', source_line(input)],
        [:T_IDENT, 'A', source_line(input, 1, 9)],
        [:T_IDENT, 'B', source_line(input, 1, 11)],
        [:T_IDENT, 'C', source_line(input, 1, 13)],
      ]
    end

    example 'lex the %left directive' do
      input = '%left A B C'

      lex(input).should == [
        [:T_LEFT, '%left', source_line(input)],
        [:T_IDENT, 'A', source_line(input, 1, 7)],
        [:T_IDENT, 'B', source_line(input, 1, 9)],
        [:T_IDENT, 'C', source_line(input, 1, 11)],
      ]
    end

    example 'lex the %right directive' do
      input = '%right A B C'

      lex(input).should == [
        [:T_RIGHT, '%right', source_line(input)],
        [:T_IDENT, 'A', source_line(input, 1, 8)],
        [:T_IDENT, 'B', source_line(input, 1, 10)],
        [:T_IDENT, 'C', source_line(input, 1, 12)],
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
        [:T_INNER, '%inner', source_line(input)],
        [:T_RUBY, "\n  foo\n  bar\n", source_line(input, 1)]
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
        [:T_HEADER, '%header', source_line(input)],
        [:T_RUBY, "\n  foo\n  bar\n", source_line(input, 1)]
      ]
    end
  end
end
