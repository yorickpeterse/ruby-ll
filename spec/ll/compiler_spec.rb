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

  describe '#on_inner' do
    before do
      @node = s(:inner, s(:ruby, 'foo'))
    end

    it 'sets the inner block' do
      @compiler.on_inner(@node, @compiled)

      @compiled.inner.should == 'foo'
    end
  end

  describe '#on_header' do
    before do
      @node = s(:header, s(:ruby, 'foo'))
    end

    it 'sets the header block' do
      @compiler.on_header(@node, @compiled)

      @compiled.header.should == 'foo'
    end
  end

  describe '#on_ruby' do
    it 'returns the Ruby code as a String' do
      node = s(:ruby, 'foo')

      @compiler.on_ruby(node, @compiled).should == 'foo'
    end
  end

  describe '#on_ident' do
    it 'returns the identifier name as a String' do
      node = s(:ident, 'foo')

      @compiler.on_ident(node, @compiled).should == 'foo'
    end
  end

  describe '#on_epsilon' do
    before do
      @source_line = source_line('foo')

      @node = LL::AST::Node.new(:epsilon, [], :source_line => @source_line)
    end

    it 'returns an Epsilon' do
      retval = @compiler.on_epsilon(@node, @compiled)

      retval.is_a?(LL::Epsilon).should == true
    end

    it 'sets the source line of the Epsilon' do
      retval = @compiler.on_epsilon(@node, @compiled)

      retval.source_line.should == @source_line
    end
  end
end
