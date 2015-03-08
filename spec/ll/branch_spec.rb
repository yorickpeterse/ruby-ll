require 'spec_helper'

describe LL::Branch do
  describe '#initialize' do
    it 'sets the steps' do
      line   = source_line('')
      steps  = [LL::Epsilon.new(line)]
      branch = described_class.new(steps, line)

      branch.steps.should == steps
    end

    it 'sets the Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)], line, 'foo')

      branch.ruby_code.should == 'foo'
    end
  end

  describe '#first_set' do
    before do
      @source_line = source_line('')
    end

    it 'returns the first set as an Array when the first step is a terminal' do
      term = LL::Terminal.new('A', @source_line)

      described_class.new([term], @source_line).first_set.should == [term]
    end

    it 'returns the first set as an Array when the first step is a rule' do
      term = LL::Terminal.new('A', @source_line)
      rule = LL::Rule.new('A', @source_line)

      rule.add_branch([term], @source_line)

      described_class.new([rule], @source_line).first_set.should == [term]
    end

    it 'returns an empty Array for a branch without any steps' do
      described_class.new([], @source_line).first_set.should == []
    end
  end

  describe '#inspect' do
    it 'returns the inspect output without Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)], line)

      branch.inspect.should == 'Branch(steps: [Epsilon()], ruby_code: nil)'
    end

    it 'returns the inspect output with Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)], line, 'foo')

      branch.inspect.should == 'Branch(steps: [Epsilon()], ruby_code: "foo")'
    end
  end
end
