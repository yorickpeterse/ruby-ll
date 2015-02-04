require 'spec_helper'

describe LL::Rule do
  describe 'anonymous' do
    before do
      @source_line = source_line('')
    end

    it 'returns a Rule' do
      rule = described_class.anonymous('foo', @source_line)

      rule.should be_an_instance_of(described_class)
    end

    it 'sets a semi random rule name' do
      rule = described_class.anonymous('foo', @source_line)

      rule.name.should =~ /foo\w+/
    end
  end

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

      rule.add_branch([LL::Epsilon.new(line)], line, 'foo')

      rule.branches[0].should be_an_instance_of(LL::Branch)
    end
  end

  describe '#increment_references' do
    it 'increments the reference count' do
      rule = described_class.new('foo', source_line(''))

      rule.increment_references

      rule.references.should == 1
    end
  end

  describe '#first_set' do
    before do
      @source_line = source_line('')
    end

    describe 'when using a single branch' do
      it 'returns the first set as an Array when using only terminals' do
        rule = described_class.new('A', @source_line)
        term = LL::Terminal.new('A', @source_line)

        rule.add_branch([term], @source_line)

        rule.first_set.should == [term]
      end

      it 'returns the first set as an Array when using terminals and rules' do
        rule1 = described_class.new('A', @source_line)
        rule2 = described_class.new('B', @source_line)
        term  = LL::Terminal.new('A', @source_line)

        rule1.add_branch([rule2], @source_line)
        rule2.add_branch([term], @source_line)

        rule1.first_set.should == [term]
      end
    end

    describe 'when using multiple branches' do
      it 'returns the first set as an Array when using only terminals' do
        rule  = described_class.new('A', @source_line)
        term1 = LL::Terminal.new('A', @source_line)
        term2 = LL::Terminal.new('B', @source_line)

        rule.add_branch([term1], @source_line)
        rule.add_branch([term2], @source_line)

        rule.first_set.should == [term1, term2]
      end

      it 'returns the first set as an Array when using terminals and rules' do
        rule1 = described_class.new('A', @source_line)
        rule2 = described_class.new('B', @source_line)
        term1 = LL::Terminal.new('A', @source_line)
        term2 = LL::Terminal.new('B', @source_line)

        rule1.add_branch([rule2], @source_line)
        rule2.add_branch([term1], @source_line)
        rule2.add_branch([term2], @source_line)

        rule1.first_set.should == [term1, term2]
      end
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      rule = described_class.new('foo', source_line(''))

      rule.inspect.should == 'Rule(name: "foo", branches: [])'
    end
  end
end
