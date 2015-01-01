require 'spec_helper'

describe LL::SourceLine do
  context '#source' do
    example 'return the source code of the line' do
      line = described_class.new(<<-EOF.strip, 2, 3)
# Foo
  bar
      EOF

      line.source.should == '  bar'
    end
  end

  context '#==' do
    before do
      @line = described_class.new('foo', 1, 1)
    end

    example 'return false when comparing SourceLine with a Fixnum' do
      @line.should_not == 10
    end

    example 'return false if two SourceLine filenames do not match' do
      @line.should_not == described_class.new('foo', 1, 1, '(bar)')
    end

    example 'return false if two SourceLine line numbers do not match' do
      @line.should_not == described_class.new('foo', 2, 1)
    end

    example 'return false if two SourceLine column numbers do not match' do
      @line.should_not == described_class.new('foo', 1, 2)
    end

    example 'return true if two SourceLine instances are equal' do
      @line.should == described_class.new('foo', 1, 1)
    end
  end
end