require 'spec_helper'

describe LL::Parser do
  describe '#parse' do
    it 'parses an empty grammar' do
      described_class.new('').parse.should == s(:grammar)
    end

    describe 'parsing invalid stack input' do
      it 'raises a ParserError' do
        block = -> { described_class.new('%name;').parse }

        block.should raise_error(
          LL::ParserError,
          /Unexpected rule \d+ for :T_SEMICOLON/
        )
      end
    end

    describe 'parsing unexpected input' do
      it 'raises a ParserError' do
        block = -> { described_class.new(';').parse }

        block.should raise_error(
          LL::ParserError,
          "Received token -1 but there's nothing left to parse"
        )
      end
    end

    describe 'parsing invalid input terminals' do
      it 'raises a ParserError when reaching EOF' do
        block = -> { described_class.new('%name Foo').parse }

        block.should raise_error(
          LL::ParserError,
          'Reached EOF while expecting terminal :T_SEMICOLON'
        )
      end

      it 'raises a ParserError when reaching an unexpected terminal' do
        block = -> { described_class.new('%name Foo:Bar;').parse }

        block.should raise_error(
          LL::ParserError,
          'Invalid terminal :T_IDENT, expected :T_COLON'
        )
      end
    end

    describe 'using the %name directive' do
      it 'parses when using just a name' do
        ast = described_class.new('%name A;').parse

        ast.should == s(:grammar, s(:name, s(:ident, 'A')))
      end

      it 'parses when using a namespace' do
        ast = described_class.new('%name A::B;').parse

        ast.should == s(:grammar, s(:name, s(:ident, 'A'), s(:ident, 'B')))
      end
    end

    describe 'using the %terminals directive' do
      it 'parses when using a single terminal' do
        ast = described_class.new('%terminals A;').parse

        ast.should == s(:grammar, s(:terminals, s(:ident, 'A')))
      end

      it 'parses when using multiple terminals' do
        ast = described_class.new('%terminals A B;').parse

        ast.should == s(:grammar, s(:terminals, s(:ident, 'A'), s(:ident, 'B')))
      end
    end

    describe 'using the %inner directive' do
      it 'parses when using no Ruby code' do
        ast = described_class.new('%inner {}').parse

        ast.should == s(:grammar, s(:inner, s(:ruby, '')))
      end

      it 'parses when using Ruby code' do
        ast = described_class.new('%inner { 10 }').parse

        ast.should == s(:grammar, s(:inner, s(:ruby, ' 10 ')))
      end
    end

    describe 'using the %header directive' do
      it 'parses when using no Ruby code' do
        ast = described_class.new('%header {}').parse

        ast.should == s(:grammar, s(:header, s(:ruby, '')))
      end

      it 'parses when using Ruby code' do
        ast = described_class.new('%header { 10 }').parse

        ast.should == s(:grammar, s(:header, s(:ruby, ' 10 ')))
      end
    end

    describe 'using rules' do
      it 'parses when using a single rule' do
        ast = described_class.new('A = B;').parse

        ast.should == s(
          :grammar,
          s(:rule, s(:ident, 'A'), s(:branch, s(:steps, s(:ident, 'B'))))
        )
      end

      it 'parses when using multiple rules' do
        ast = described_class.new('A = B; C = D;').parse

        ast.should == s(
          :grammar,
          s(:rule, s(:ident, 'A'), s(:branch, s(:steps, s(:ident, 'B')))),
          s(:rule, s(:ident, 'C'), s(:branch, s(:steps, s(:ident, 'D'))))
        )
      end

      it 'parses when using a Ruby callback' do
        ast = described_class.new('A = B { 10 };').parse

        ast.should == s(
          :grammar,
          s(
            :rule,
            s(:ident, 'A'),
            s(:branch, s(:steps, s(:ident, 'B')), s(:ruby, ' 10 '))
          )
        )
      end

      it 'parses when using an epsilon' do
        ast = described_class.new('A = _;').parse

        ast.should == s(
          :grammar,
          s(:rule, s(:ident, 'A'), s(:branch, s(:steps, s(:epsilon))))
        )
      end

      it 'parses when using multiple branches and an epsilon' do
        ast = described_class.new('A = B | _;').parse

        ast.should == s(
          :grammar,
          s(
            :rule,
            s(:ident, 'A'),
            s(:branch, s(:steps, s(:ident, 'B'))),
            s(:branch, s(:steps, s(:epsilon)))
          )
        )
      end
    end
  end
end
