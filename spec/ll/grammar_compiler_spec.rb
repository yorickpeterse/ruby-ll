require 'spec_helper'

describe LL::GrammarCompiler do
  before do
    @compiler = described_class.new
    @compiled = LL::CompiledGrammar.new
  end

  describe '#compile' do
    before do
      @node = s(
        :grammar,
        s(:terminals, s(:ident, 'A'), s(:ident, 'B')),
        s(:rule, s(:ident, 'foo'), s(:branch, s(:steps, s(:ident, 'A')))),
        s(:rule, s(:ident, 'bar'), s(:branch, s(:steps, s(:ident, 'A'))))
      )
    end

    it 'processes the AST' do
      @compiler.should_receive(:process)

      @compiler.compile(@node)
    end

    it 'adds warnings for unused terminals' do
      @compiler.should_receive(:warn_for_unused_terminals)

      @compiler.compile(@node)
    end

    it 'adds warnings for unused rules' do
      @compiler.should_receive(:warn_for_unused_rules)

      @compiler.compile(@node)
    end
  end

  describe '#on_grammar' do
    before do
      @node = s(
        :grammar,
        s(:rule, s(:ident, 'foo'), s(:branch, s(:steps, s(:ident, 'A'))))
      )
    end

    it 'builds a rule prototype' do
      @compiler.should_receive(:on_rule_prototype).and_call_original

      @compiler.on_grammar(@node, @compiled)
    end

    it 'builds a rule' do
      @compiler.should_receive(:on_rule).and_call_original

      @compiler.on_grammar(@node, @compiled)
    end
  end

  describe '#warn_for_unused_rules' do
    before do
      @compiled.add_rule(LL::Rule.new('foo', source_line('')))
      @compiled.add_rule(LL::Rule.new('bar', source_line('')))
    end

    it 'adds warnings for unused rules except for the first rule' do
      @compiler.warn_for_unused_rules(@compiled)

      @compiled.warnings.length.should == 1
      @compiled.warnings[0].should be_an_instance_of(LL::Message)
    end
  end

  describe '#warn_for_unused_terminals' do
    before do
      @compiled.add_terminal('foo', source_line(''))
    end

    it 'adds warnings for unused terminals' do
      @compiler.warn_for_unused_terminals(@compiled)

      @compiled.warnings.length.should == 1
      @compiled.warnings[0].should be_an_instance_of(LL::Message)
    end
  end

  describe '#verify_first_first' do
    describe 'when there are no conflicts' do
      before do
        line = source_line('')
        term = LL::Terminal.new('A', line)
        rule = LL::Rule.new('A', line)

        rule.add_branch([term], line)

        @compiled.add_rule(rule)
      end

      it 'does not add any errors' do
        @compiler.verify_first_first(@compiled)

        @compiled.errors.should be_empty
      end
    end

    describe 'when two branches conflict' do
      before do
        line  = source_line('')
        term  = LL::Terminal.new('A', line)
        rule1 = LL::Rule.new('A', line)
        rule2 = LL::Rule.new('B', line)
        eps   = LL::Epsilon.new(line)

        rule1.add_branch([term], line)
        rule1.add_branch([rule2], line)

        rule2.add_branch([term], line)
        rule2.add_branch([eps], line)

        @compiled.add_rule(rule1)
        @compiled.add_rule(rule2)
      end

      it 'adds 3 errors' do
        @compiler.verify_first_first(@compiled)

        @compiled.errors.length.should == 3
      end

      it 'adds an error for the entire rule' do
        @compiler.verify_first_first(@compiled)

        @compiled.errors[0].message.should =~ %r{first/first conflict}
      end

      it 'adds an error for the first branch' do
        @compiler.verify_first_first(@compiled)

        @compiled.errors[1].message.should == 'branch starts with: A'
      end

      it 'adds an error for the second branch' do
        @compiler.verify_first_first(@compiled)

        @compiled.errors[2].message.should == 'branch starts with: A, epsilon'
      end
    end
  end

  describe '#verify_first_follow' do
    describe 'when no first/follow conflict is present' do
      before do
        line = source_line('')
        rule = LL::Rule.new('rule1', line)

        termA = @compiled.add_terminal('A', line)
        termB = @compiled.add_terminal('B', line)
        eps   = LL::Epsilon.new(line)

        rule.add_branch([termA, termB, eps], line)

        @compiled.add_rule(rule)
      end

      it 'adds no errors' do
        @compiler.verify_first_follow(@compiled)

        @compiled.errors.should be_empty
      end
    end

    describe 'when a first/follow conflict is present' do
      before do
        # rule1 = rule2 A;
        # rule2 = B | _;
        line  = source_line('')
        rule1 = LL::Rule.new('rule1', line)
        rule2 = LL::Rule.new('rule2', line)

        termA = @compiled.add_terminal('A', line)
        termB = @compiled.add_terminal('B', line)
        eps   = LL::Epsilon.new(line)

        rule1.add_branch([rule2, termA], line)
        rule2.add_branch([termB], line)
        rule2.add_branch([eps], line)

        @compiled.add_rule(rule1)
        @compiled.add_rule(rule2)
      end

      it 'adds two errors' do
        @compiler.verify_first_follow(@compiled)

        @compiled.errors.length.should == 2
      end

      it 'adds an error for the conflicting branch' do
        @compiler.verify_first_follow(@compiled)

        @compiled.errors[0].message.should =~ %r{first/follow conflict}
      end

      it 'adds an error for the epsilon' do
        @compiler.verify_first_follow(@compiled)

        @compiled.errors[1].message.should == 'epsilon originates from here'
      end
    end
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
          'the rule "foo" has already been defined'
      end

      it 'does not overwrite the existing rule' do
        @compiler.on_rule(@node, @compiled)

        @rule.branches.should_not receive(:concat)

        @compiler.on_rule(@node, @compiled)
      end
    end

    describe 'when defining a rule with the same name as a terminal' do
      before do
        @compiled.add_terminal('foo', source_line(''))
      end

      it 'adds an error' do
        @compiler.on_rule(@node, @compiled)

        @compiled.errors[0].message.should ==
          'the rule name "foo" is already used as a terminal name'
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
end
