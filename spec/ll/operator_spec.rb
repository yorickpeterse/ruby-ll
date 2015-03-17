require 'spec_helper'

describe LL::Operator do
  before do
    @line     = source_line('A')
    @rule     = LL::Rule.new('A', @line)
    @operator = described_class.new(:plus, @rule, @line)
  end

  describe '#type' do
    it 'returns the type of the operator as a Symbol' do
      operator = described_class.new(:plus, @rule, @line)

      operator.type.should == :plus
    end
  end

  describe '#receiver' do
    it 'returns the receiver of the operator' do
      operator = described_class.new(:plus, @rule, @line)

      operator.receiver.should == @rule
    end
  end

  describe '#source_line' do
    it 'returns a SourceLine' do
      operator = described_class.new(:plus, @rule, @line)

      operator.source_line.should == @line
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      operator = described_class.new(:plus, @rule, @line)

      operator.inspect.should ==
        'Operator(type: :plus, receiver: Rule(name: "A", branches: []))'
    end
  end
end
