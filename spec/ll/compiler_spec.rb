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

      retval.should be_an_instance_of(LL::Epsilon)
    end

    it 'sets the source line of the Epsilon' do
      retval = @compiler.on_epsilon(@node, @compiled)

      retval.source_line.should == @source_line
    end
  end

  describe '#on_rule' do
    before do
      @node = s(
        :rule,
        s(:ident, 'foo'),
        s(:branch, s(:steps, s(:ident, 'A')), s(:ruby, 'foo'))
      )

      @rule = LL::Rule.new('foo', source_line(''))

      @compiled.add_rule(@rule)
      @compiled.add_terminal('A', source_line(''))
    end

    it 'sets the rule branches' do
      @compiler.on_rule(@node, @compiled)

      @rule.branches.length.should == 1
    end

    it 'sets the steps of the branch' do
      @compiler.on_rule(@node, @compiled)

      @rule.branches[0].steps.length.should == 1
    end

    it 'sets the Ruby code of the branch' do
      @compiler.on_rule(@node, @compiled)

      @rule.branches[0].ruby_code.should == 'foo'
    end

    describe 'with an existing rule' do
      it 'adds an error message' do
        @compiler.on_rule(@node, @compiled)
        @compiler.on_rule(@node, @compiled)

        @compiled.errors[0].message.should ==
          'The rule "foo" has already been defined'
      end

      it 'does not overwrite the existing rule' do
        @compiler.on_rule(@node, @compiled)

        @rule.branches.should_not receive(:concat)

        @compiler.on_rule(@node, @compiled)
      end
    end
  end

  describe '#on_rule_prototype' do
    before do
      @source_line = source_line('foo')

      @node = LL::AST::Node.new(
        :rule,
        [s(:ident, 'foo')],
        :source_line => @source_line
      )
    end

    it 'defines the prototype of a rule' do
      @compiler.on_rule_prototype(@node, @compiled)

      @compiled.has_rule?('foo').should == true
    end
  end

  describe '#on_branch' do
    before do
      @node = s(:branch, s(:steps, s(:ident, 'A')), s(:ruby, 'foo'))

      @compiled.add_terminal('A', source_line('A'))
    end

    it 'returns a Branch' do
      branch = @compiler.on_branch(@node, @compiled)

      branch.should be_an_instance_of(LL::Branch)
    end

    it 'sets the steps of the branch' do
      branch = @compiler.on_branch(@node, @compiled)

      branch.steps.length.should == 1
    end

    it 'sets the Ruby code of the branch' do
      branch = @compiler.on_branch(@node, @compiled)

      branch.ruby_code.should == 'foo'
    end
  end

  describe '#on_steps' do
    describe 'when using identifiers' do
      before do
        @node = s(:steps, s(:ident, 'A'))
      end

      it 'returns the steps as an Array' do
        @terminal = @compiled.add_terminal('A', source_line('A'))

        @compiler.on_steps(@node, @compiled).should == [@terminal]
      end

      it 'increments the reference count of the terminal' do
        @terminal = @compiled.add_terminal('A', source_line('A'))

        @compiler.on_steps(@node, @compiled)

        @terminal.references.should == 1
      end

      it 'adds an error for an undefined identifier' do
        @compiler.on_steps(@node, @compiled)

        @compiled.errors[0].message.should == 'Undefined terminal or rule "A"'
      end
    end

    describe 'when using non identifiers' do
      before do
        @node = s(:steps, s(:epsilon))
      end

      it 'returns the steps as an Array' do
        steps = @compiler.on_steps(@node, @compiled)

        steps[0].should be_an_instance_of(LL::Epsilon)
      end
    end
  end

  describe '#on_star' do
    before do
      @node     = s(:star, s(:ident, 'A'))
      @terminal = @compiled.add_terminal('A', source_line('A'))
    end

    it 'returns a Rule' do
      rule = @compiler.on_star(@node, @compiled)

      rule.should be_an_instance_of(LL::Rule)
    end

    it 'sets the name of the first rule' do
      @compiler.on_star(@node, @compiled).name.should == '_A1'
    end

    it 'adds two branches to the first rule' do
      rule = @compiler.on_star(@node, @compiled)

      rule.branches.length.should == 2
    end

    it 'sets the steps of the first branch of the first rule' do
      branch = @compiler.on_star(@node, @compiled).branches[0]

      branch.steps.length.should == 1

      branch.steps[0].should be_an_instance_of(LL::Rule)
    end

    it 'sets the steps of the second branch of the first rule' do
      branch = @compiler.on_star(@node, @compiled).branches[1]

      branch.steps.length.should == 1

      branch.steps[0].should be_an_instance_of(LL::Epsilon)
    end

    it 'sets the name of the second rule' do
      rule1 = @compiler.on_star(@node, @compiled)
      rule2 = rule1.branches[0].steps[0]

      rule2.name.should == '_A2'
    end

    it 'adds a single branch to the second rule' do
      rule1 = @compiler.on_star(@node, @compiled)
      rule2 = rule1.branches[0].steps[0]

      rule2.branches.length.should == 1
    end

    it 'sets the steps of the first branch of the second rule' do
      rule1  = @compiler.on_star(@node, @compiled)
      rule2  = rule1.branches[0].steps[0]
      branch = rule2.branches[0]

      branch.steps.length.should == 2

      branch.steps[0].should == @terminal
      branch.steps[1].should == rule1
    end
  end

  describe '#on_plus' do
    before do
      @node     = s(:plus, s(:ident, 'A'))
      @terminal = @compiled.add_terminal('A', source_line('A'))
    end

    it 'returns a Rule' do
      rule = @compiler.on_plus(@node, @compiled)

      rule.should be_an_instance_of(LL::Rule)
    end

    it 'sets the name of the first rule' do
      @compiler.on_plus(@node, @compiled).name.should == '_A1'
    end

    it 'adds a single branch to the first rule' do
      rule = @compiler.on_plus(@node, @compiled)

      rule.branches.length.should == 1
    end

    it 'sets the steps of the first branch of the first rule' do
      branch = @compiler.on_plus(@node, @compiled).branches[0]

      branch.steps.length.should == 2

      branch.steps[0].should == @terminal

      branch.steps[1].should be_an_instance_of(LL::Rule)
    end

    it 'sets the name of the second rule' do
      rule1 = @compiler.on_plus(@node, @compiled)
      rule2 = rule1.branches[0].steps[1]

      rule2.name.should == '_A2'
    end

    it 'adds a single branch to the second rule' do
      rule1 = @compiler.on_plus(@node, @compiled)
      rule2 = rule1.branches[0].steps[1]

      rule2.branches.length.should == 1
    end

    it 'sets the steps of the first branch of the second rule' do
      rule1  = @compiler.on_plus(@node, @compiled)
      rule2  = rule1.branches[0].steps[1]
      branch = rule2.branches[0]

      branch.steps.length.should == 2

      branch.steps[0].should == rule1

      branch.steps[1].should be_an_instance_of(LL::Epsilon)
    end
  end

  describe '#on_question' do
    before do
      @node     = s(:question, s(:ident, 'A'))
      @terminal = @compiled.add_terminal('A', source_line('A'))
    end

    it 'returns a Rule' do
      rule = @compiler.on_question(@node, @compiled)

      rule.should be_an_instance_of(LL::Rule)
    end

    it 'sets the name of the first rule' do
      rule = @compiler.on_question(@node, @compiled)

      rule.name.should == '_A1'
    end

    it 'adds two branches to the first rule' do
      rule = @compiler.on_question(@node, @compiled)

      rule.branches.length.should == 2
    end

    it 'sets the steps of the first branch' do
      branch = @compiler.on_question(@node, @compiled).branches[0]

      branch.steps.length.should == 1
      branch.steps[0].should     == @terminal
    end

    it 'sets the steps of the second branch' do
      branch = @compiler.on_question(@node, @compiled).branches[1]

      branch.steps.length.should == 1

      branch.steps[0].should be_an_instance_of(LL::Epsilon)
    end
  end
end
