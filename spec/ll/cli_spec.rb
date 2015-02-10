require 'spec_helper'

describe LL::CLI do
  before do
    @cli = described_class.new
  end

  describe '#output_from_input' do
    it 'returns the output path for an input path' do
      @cli.output_from_input('foo/bar/baz.rll').should == 'foo/bar/baz.rb'
    end
  end
end
