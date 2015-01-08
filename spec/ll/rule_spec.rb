require 'spec_helper'

describe LL::Rule do
  describe '#intialize' do
    before do
      @source_line = source_line('')
      @rule        = described_class.new('foo', @source_line)
    end

    it 'sets the name' do
      @rule.name.should == 'foo'
    end

    it 'sets the branches to an empty Array' do
      @rule.branches.should == []
    end

    it 'sets the source line' do
      @rule.source_line.should == @source_line
    end

    it 'sets the default reference count' do
      @rule.references.should == 0
    end
  end

  describe '#add_branch' do
    it 'adds a new branch' do
      line = source_line('')
      rule = described_class.new('foo', line)

      rule.add_branch([LL::Epsilon.new(line)], 'foo')

      rule.branches[0].is_a?(LL::Branch).should == true
    end
  end

  describe '#increment_references' do
    it 'increments the reference count' do
      rule = described_class.new('foo', source_line(''))

      rule.increment_references

      rule.references.should == 1
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      rule = described_class.new('foo', source_line(''))

      rule.inspect.should == 'Rule(name: "foo", branches: [])'
    end
  end
end
