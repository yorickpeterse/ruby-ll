require 'spec_helper'

describe LL::CompiledConfiguration do
  describe '#initialize' do
    describe 'without custom values' do
      before do
        @compiled = described_class.new
      end

      it 'sets a default Array for the terminals' do
        @compiled.terminals.should == []
      end

      it 'sets a default Array for the rules' do
        @compiled.rules.should == []
      end

      it 'sets a default Array for the table' do
        @compiled.table.should == []
      end

      it 'sets a default Array for the actions' do
        @compiled.actions.should == []
      end

      it 'sets a default Hash for the action bodies' do
        @compiled.action_bodies.should == {}
      end

      it 'sets a default Array for the namespace' do
        @compiled.namespace.should == []
      end
    end

    describe 'with custom values' do
      it 'sets a custom list of terminals' do
        described_class.new(:terminals => [:A]).terminals.should == [:A]
      end
    end
  end
end
