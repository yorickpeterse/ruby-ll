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
end
