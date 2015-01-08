require 'spec_helper'

describe LL::Branch do
  describe '#initialize' do
    it 'sets the steps' do
      line   = source_line('')
      steps  = [LL::Epsilon.new(line)]
      branch = described_class.new(steps)

      branch.steps.should == steps
    end

    it 'sets the Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)], 'foo')

      branch.ruby_code.should == 'foo'
    end
  end

  describe '#inspect' do
    it 'returns the inspect output without Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)])

      branch.inspect.should == 'Branch(steps: [Epsilon()], ruby_code: nil)'
    end

    it 'returns the inspect output with Ruby code' do
      line   = source_line('')
      branch = described_class.new([LL::Epsilon.new(line)], 'foo')

      branch.inspect.should == 'Branch(steps: [Epsilon()], ruby_code: "foo")'
    end
  end
end
