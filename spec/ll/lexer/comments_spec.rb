require 'spec_helper'

describe LL::Lexer do
  describe 'using comments' do
    it 'lexes a single comment' do
      lex('# foo').should == []
    end

    it 'lexes multiple comments' do
      input = <<-EOF.strip
# foo
# bar
      EOF

      lex(input).should == []
    end
  end
end
