require 'spec_helper'

describe LL::CompiledParser do
  before do
    @source_line = source_line('foo')
    @compiled    = described_class.new
  end

  describe '#add_error' do
    before do
      @compiled.add_error('Hello', @source_line)
    end

    it 'adds a new error message' do
      @compiled.errors.empty?.should == false
    end

    it 'sets the type of the message' do
      @compiled.errors[0].type.should == :error
    end

    it 'sets the message of the error' do
      @compiled.errors[0].message.should == 'Hello'
    end

    it 'sets the source line of the message' do
      @compiled.errors[0].source_line.should == @source_line
    end
  end

  describe '#add_warning' do
    before do
      @compiled.add_warning('Hello', @source_line)
    end

    it 'adds a new warning message' do
      @compiled.warnings.empty?.should == false
    end

    it 'sets the type of the message' do
      @compiled.warnings[0].type.should == :warning
    end

    it 'sets the message of the warning' do
      @compiled.warnings[0].message.should == 'Hello'
    end

    it 'sets the source line of the message' do
      @compiled.warnings[0].source_line.should == @source_line
    end
  end

  describe '#has_terminal?' do
    it 'returns false for a non existing terminal' do
      @compiled.has_terminal?('foo').should == false
    end

    it 'returns true for an existing terminal' do
      @compiled.add_terminal('foo', @source_line)

      @compiled.has_terminal?('foo').should == true
    end
  end

  describe '#add_terminal' do
    it 'adds a new terminal' do
      @compiled.add_terminal('foo', @source_line)

      @compiled.terminals.empty?.should == false
    end
  end

  describe '#has_rule?' do
    it 'returns false for a non existing rule' do
      @compiled.has_rule?('foo').should == false
    end

    it 'returns true for an existing rule' do
      rule = LL::Rule.new('foo', @source_line)

      @compiled.add_rule(rule)

      @compiled.has_rule?('foo').should == true
    end
  end

  describe '#has_rule_with_branches?' do
    it 'returns false for a non existing rule' do
      @compiled.has_rule_with_branches?('foo').should == false
    end

    it 'returns false for an existing rule without any branches' do
      rule = LL::Rule.new('foo', @source_line)

      @compiled.add_rule(rule)

      @compiled.has_rule_with_branches?('foo').should == false
    end

    it 'returns true for an existing rule with a single branch' do
      rule = LL::Rule.new('foo', @source_line)

      rule.add_branch([LL::Epsilon.new(@source_line)], @source_line)

      @compiled.add_rule(rule)

      @compiled.has_rule_with_branches?('foo').should == true
    end
  end

  describe '#lookup_rule' do
    it 'returns nil for a non existing rule' do
      @compiled.lookup_rule('foo').should be_nil
    end

    it 'returns a Rule for an existing rule' do
      rule = LL::Rule.new('foo', @source_line)

      @compiled.add_rule(rule)

      @compiled.lookup_rule('foo').should == rule
    end
  end

  describe '#lookup_identifier' do
    it 'returns a Rule for an existing rule' do
      rule = LL::Rule.new('foo', @source_line)

      @compiled.add_rule(rule)

      @compiled.lookup_identifier('foo').should == rule
    end

    it 'returns a Terminal for an existing terminal' do
      terminal = @compiled.add_terminal('foo', @source_line)

      @compiled.lookup_identifier('foo').should == terminal
    end

    it 'returns nil for a non existing identifier' do
      @compiled.lookup_identifier('foo').should be_nil
    end
  end

  describe '#rules' do
    it 'returns an empty Array by default' do
      @compiled.rules.should == []
    end

    it 'returns an Array containing all the rules' do
      rule = LL::Rule.new('foo', @source_line)

      @compiled.add_rule(rule)

      @compiled.rules.should == [rule]
    end
  end

  describe '#terminals' do
    it 'returns an empty Array by default' do
      @compiled.terminals.should == []
    end

    it 'returns an Array containing all the terminals' do
      terminal = @compiled.add_terminal('foo', @source_line)

      @compiled.terminals.should == [terminal]
    end
  end

  describe '#terminal_index' do
    before do
      line = source_line('')

      @term1 = @compiled.add_terminal('A', line)
      @term2 = @compiled.add_terminal('B', line)
    end

    it 'returns the index of the first terminal' do
      @compiled.terminal_index(@term1).should == 0
    end

    it 'returns the index of the second terminal' do
      @compiled.terminal_index(@term2).should == 1
    end
  end

  describe '#rule_index' do
    before do
      line = source_line('')

      @rule1 = LL::Rule.new('A', line)
      @rule2 = LL::Rule.new('B', line)

      @compiled.add_rule(@rule1)
      @compiled.add_rule(@rule2)
    end

    it 'returns the index of the first rule' do
      @compiled.rule_index(@rule1).should == 0
    end

    it 'returns the index of the second rule' do
      @compiled.rule_index(@rule2).should == 1
    end
  end

  describe '#valid?' do
    it 'returns true when there are no errors' do
      @compiled.valid?.should == true
    end

    it 'returns false when there are any errors' do
      @compiled.add_error('Foo', @source_line)

      @compiled.valid?.should == false
    end
  end

  describe '#display_messages' do
    before do
      @buffer = StringIO.new

      @compiled.stub(:output).and_return(@buffer)
    end

    it 'displays the messages' do
      @compiled.add_error('Hello', @source_line)
      @compiled.display_messages

      @buffer.rewind

      @buffer.read.should =~ /Hello/
    end
  end
end
