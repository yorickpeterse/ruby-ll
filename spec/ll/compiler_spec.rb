require 'spec_helper'

describe LL::Compiler do
  before do
    @compiler = described_class.new
    @compiled = LL::CompiledParser.new
  end

  describe '#on_name' do
    before do
      @node = s(:name, s(:ident, 'Foo'), s(:ident, 'Bar'))
    end

    it 'sets the parser name' do
      @compiler.on_name(@node, @compiled)

      @compiled.name.should == 'Foo::Bar'
    end

    describe 'with an existing parser name' do
      before do
        @compiled.name = 'Alice'

        @compiler.on_name(@node, @compiled)
      end

      it 'overwrites the parser name' do
        @compiled.name.should == 'Foo::Bar'
      end

      it 'adds a warning message' do
        @compiled.warnings[0].message.should ==
          'Overwriting existing parser name "Alice"'
      end
    end
  end

  describe '#on_terminals' do
    before do
      @node = s(:terminals, s(:ident, 'A'))
    end

    it 'defines a new terminal' do
      @compiler.on_terminals(@node, @compiled)

      @compiled.has_terminal?('A').should == true
    end

    describe 'with an existing terminal' do
      before do
        @compiler.on_terminals(@node, @compiled)
      end

      it 'does not overwrite the existing terminal' do
        @compiled.should_not receive(:add_terminal)

        @compiler.on_terminals(@node, @compiled)
      end

      it 'adds an error message' do
        @compiler.on_terminals(@node, @compiled)

        @compiled.errors[0].message.should ==
          'The terminal "A" has already been defined'
      end
    end
  end
end
