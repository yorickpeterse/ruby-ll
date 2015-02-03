require 'spec_helper'

describe LL::ConfigurationCompiler do
  before do
    @compiled = LL::CompiledGrammar.new

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

    termA = @compiled.add_terminal('A', line)
    termB = @compiled.add_terminal('B', line)
    eps   = LL::Epsilon.new(line)

    rule1.add_branch([rule2], line)
    rule1.add_branch([eps], line)

    rule2.add_branch([termA], line, " 'A' ")
    rule2.add_branch([termB], line, " 'B' ")

    @compiled.add_rule(rule1)
    @compiled.add_rule(rule2)

    @compiler = described_class.new
  end

  describe '#generate' do
    it 'returns a CompiledConfiguration instance' do
      config = @compiler.generate(@compiled)

      config.should be_an_instance_of(LL::CompiledConfiguration)
    end

    it 'sets the list of terminals as Symbols' do
      config = @compiler.generate(@compiled)

      config.terminals.should == [:A, :B]
    end

    it 'sets the rules table as an Array' do
      config = @compiler.generate(@compiled)

      config.rules.should == [
        [0, 1],
        [2, 0],
        [3, 0, 1, 0],
        [3, 1, 1, 1]
      ]
    end

    it 'sets the lookup table as an Array' do
      config = @compiler.generate(@compiled)

      config.table.should == [
        [0, 0],
        [2, 3]
      ]
    end

    it 'sets the actions table as an Array' do
      config = @compiler.generate(@compiled)

      config.actions.should == [
        [:_rule_0, 1],
        [:_rule_1, 1]
      ]
    end

    it 'sets the action bodies as a Hash' do
      config = @compiler.generate(@compiled)

      config.action_bodies.should == {
        :_rule_0 => " 'A' ",
        :_rule_1 => " 'B' "
      }
    end
  end
end
