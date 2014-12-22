require 'spec_helper'

describe LL::Lexer do
  context 'comments' do
    example 'lex a single comment' do
      lex('# foo').should == []
    end

    example 'lex multiple comments' do
      input = <<-EOF.strip
# foo
# bar
      EOF

      lex(input).should == []
    end
  end
end
