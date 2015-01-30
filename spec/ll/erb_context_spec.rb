require 'spec_helper'

describe LL::ERBContext do
  describe '#initialize' do
    it 'sets an instance variable' do
      context = described_class.new(:number => 10)

      context.instance_variable_get(:@number).should == 10
    end
  end

  describe '#get_binding' do
    it 'returns the Binding of a context' do
      described_class.new.get_binding.should be_an_instance_of(Binding)
    end
  end
end
