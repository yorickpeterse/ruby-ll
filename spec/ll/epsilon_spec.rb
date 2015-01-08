require 'spec_helper'

describe LL::Epsilon do
  describe '#initialize' do
    it 'sets the source line' do
      line = source_line('')

      described_class.new(line).source_line.should == line
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      line = source_line('')

      described_class.new(line).inspect.should == 'Epsilon()'
    end
  end
end
