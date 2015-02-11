require 'spec_helper'

describe LL::ConfigurationCompiler do
  before do
    @grammar = LL::CompiledGrammar.new

    line = source_line('')

    # rule1
    #   = rule2
    #   | _
    #   ;
    #
    # rule2
    #   = A { 'A' }
    #   | B { 'B' }
    #   ;
    rule1 = LL::Rule.new('rule1', line)
    rule2 = LL::Rule.new('rule2', line)

    termA = @grammar.add_terminal('A', line)
    termB = @grammar.add_terminal('B', line)
    eps   = LL::Epsilon.new(line)

    rule1.add_branch([rule2], line)
    rule1.add_branch([eps], line)

    rule2.add_branch([termA], line, " 'A' ")
    rule2.add_branch([termB], line, " 'B' ")

    @grammar.add_rule(rule1)
    @grammar.add_rule(rule2)

    @grammar.name   = 'A::B::C'
    @grammar.inner  = 'foo'
    @grammar.header = 'bar'

    @compiler = described_class.new
  end

  describe '#generate' do
    it 'returns a CompiledConfiguration instance' do
      config = @compiler.generate(@grammar)

      config.should be_an_instance_of(LL::CompiledConfiguration)
    end

    it 'sets the name as a String' do
      @compiler.generate(@grammar).name.should == 'C'
    end

    it 'sets the namespace as an Array' do
      @compiler.generate(@grammar).namespace.should == %w{A B}
    end

    it 'sets the inner block as a String' do
      @compiler.generate(@grammar).inner.should == @grammar.inner
    end

    it 'sets the header block as a String' do
      @compiler.generate(@grammar).header.should == @grammar.header
    end

    it 'sets the list of terminals as Symbols' do
      config = @compiler.generate(@grammar)

      config.terminals.should == [:$EOF, :A, :B]
    end

    it 'sets the rules table as an Array' do
      config = @compiler.generate(@grammar)

      config.rules.should == [
        [3, 0, 0, 1],
        [3, 1, 2, 0],
        [3, 2, 1, 1],
        [3, 3, 1, 2]
      ]
    end

    it 'sets the lookup table as an Array' do
      config = @compiler.generate(@grammar)

      config.table.should == [
        [1, 0, 0],
        [-1, 2, 3]
      ]
    end

    it 'sets the actions table as an Array' do
      config = @compiler.generate(@grammar)

      config.actions.should == [
        [:_rule_0, 1],
        [:_rule_1, 0],
        [:_rule_2, 1],
        [:_rule_3, 1]
      ]
    end

    it 'sets the action bodies as a Hash' do
      config = @compiler.generate(@grammar)

      config.action_bodies.should == {
        :_rule_0 => 'val',
        :_rule_1 => 'val',
        :_rule_2 => " 'A' ",
        :_rule_3 => " 'B' "
      }
    end
  end

  describe '#name' do
    it 'returns the name' do
      @compiler.generate_name(@grammar).should == 'C'
    end
  end

  describe '#namespace' do
    it 'returns the namespace as an Array' do
      @compiler.generate_namespace(@grammar).should == %w{A B}
    end
  end

  describe '#generate_terminals' do
    it 'returns the terminals as an Array' do
      @compiler.generate_terminals(@grammar).should == [:$EOF, :A, :B]
    end
  end

  describe '#generate_actions' do
    it 'returns the actions as an Array' do
      @compiler.generate_actions(@grammar).should == [
        [:_rule_0, 1],
        [:_rule_1, 0],
        [:_rule_2, 1],
        [:_rule_3, 1]
      ]
    end
  end

  describe '#generate_action_bodies' do
    it 'returns the action bodies as a Hash' do
      @compiler.generate_action_bodies(@grammar).should == {
        :_rule_0 => 'val',
        :_rule_1 => 'val',
        :_rule_2 => " 'A' ",
        :_rule_3 => " 'B' "
      }
    end
  end

  describe '#generate_rules' do
    it 'returns the rules as an Array' do
      @compiler.generate_rules(@grammar).should == [
        [3, 0, 0, 1],
        [3, 1, 2, 0],
        [3, 2, 1, 1],
        [3, 3, 1, 2]
      ]
    end
  end

  describe '#generate_table' do
    it 'returns the table as an Array' do
      @compiler.generate_table(@grammar).should == [
        [1, 0, 0],
        [-1, 2, 3]
      ]
    end
  end
end
