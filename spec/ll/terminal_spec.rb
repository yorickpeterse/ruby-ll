require 'spec_helper'

describe LL::Terminal do
  describe '#initialize' do
    before do
      @source_line = source_line('')
      @terminal    = described_class.new('T_FOO', @source_line)
    end

    it 'sets the name' do
      @terminal.name.should == 'T_FOO'
    end

    it 'sets the source line' do
      @terminal.source_line.should == @source_line
    end

    it 'sets the default reference count' do
      @terminal.references.should == 0
    end
  end

  describe '#increment_references' do
    it 'increments the reference count' do
      terminal = described_class.new('T_FOO', source_line(''))

      terminal.increment_references

      terminal.references.should == 1
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      terminal = described_class.new('T_FOO', source_line(''))

      terminal.inspect.should == 'Terminal(name: "T_FOO")'
    end
  end
end
