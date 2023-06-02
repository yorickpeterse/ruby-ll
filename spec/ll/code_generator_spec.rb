require 'spec_helper'

describe LL::CodeGenerator do
  before do
    @config = LL::CompiledConfiguration.new(
      :name          => 'MyParser',
      :namespace     => %w{A B},
      :inner         => '# inner',
      :header        => '# header',
      :terminals     => [:A, :B],
      :rules         => [[1, 0, 1, 1]],
      :table         => [[0, -1]],
      :actions       => [[:_rule_0, 2]],
      :action_bodies => {:_rule_0 => 'val'}
    )

    @generator = described_class.new
  end

  describe '#generate' do
    before do
      @tempfile = Tempfile.new('ll-codegenerator')
    end

    after do
      @tempfile.close(true)
    end

    it 'returns the generated code as a String' do
      @generator.generate(@config).should be_an_instance_of(String)
    end

    unless RUBY_PLATFORM == 'opal'
      it 'returns valid Ruby code' do
        @tempfile.write(@generator.generate(@config))
        @tempfile.rewind

        output = `ruby -c #{@tempfile.path} 2>&1`

        output.should =~ /Syntax OK/
      end
    end

    it 'returns Ruby code including the inner block' do
      @generator.generate(@config).include?(@config.inner).should == true
    end

    it 'returns Ruby code including the header block' do
      @generator.generate(@config).include?(@config.header).should == true
    end
  end
end
