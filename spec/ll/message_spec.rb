require 'spec_helper'

describe LL::Message do
  describe '#initialize' do
    before do
      @source_line = source_line('')
      @message     = described_class.new(:error, 'Foobar', @source_line)
    end

    it 'sets the message type' do
      @message.type.should == :error
    end

    it 'sets the message' do
      @message.message.should == 'Foobar'
    end

    it 'sets the source line' do
      @message.source_line.should == @source_line
    end
  end

  describe '#to_s' do
    it 'returns an ANSI colored string' do
      path    = File.expand_path(__FILE__)
      type    = ANSI.ansi('error', :red, :bold)
      line    = source_line('foo = bar;', 1, 7, path)
      message = described_class.new(:error, 'Foobar!', line)

      expected = <<-EOF.strip
#{ANSI.ansi('spec/ll/message_spec.rb:1:7', :white, :bold)}:#{type}: Foobar!
foo = bar;
      #{ANSI.ansi('^', :magenta, :bold)}
      EOF

      message.to_s.should == expected
    end
  end

  describe '#inspect' do
    it 'returns the inspect output' do
      line    = source_line('')
      message = described_class.new(:error, 'foo', line)

      message.inspect.should == 'Message(type: :error, message: "foo", '\
        'file: "(ruby)", line: 1, column: 1)'
    end
  end

  describe '#determine_path' do
    it 'returns the raw path when it is a default path' do
      line    = source_line('')
      message = described_class.new(:error, 'foo', line)

      message.determine_path.should == line.file
    end

    it 'returns a path relative to the current working directory' do
      line    = source_line('', 1, 1, File.expand_path(__FILE__))
      message = described_class.new(:error, 'foo', line)

      message.determine_path.should == 'spec/ll/message_spec.rb'
    end

    it 'returns an absolute path for paths outside of the working directory' do
      path    = File.join(Dir.tmpdir, 'foo.rb')
      line    = source_line('', 1, 1, path)
      message = described_class.new(:error, 'foo', line)

      message.determine_path.should == path
    end
  end

  describe '#line' do
    it 'returns the line' do
      message = described_class.new(:error, 'foo', source_line(''))

      message.line.should == 1
    end
  end

  describe '#column' do
    it 'returns the column' do
      message = described_class.new(:error, 'foo', source_line(''))

      message.column.should == 1
    end
  end
end
