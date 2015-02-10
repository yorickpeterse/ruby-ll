require 'benchmark/ips'

require_relative '../lib/ll'
require_relative '../lib/ll/bootstrap/parser'

input = <<-EOF.strip
%name A::B;

%terminals A B;

root = A | B;
EOF

Benchmark.ips do |bench|
  bench.report 'ruby-ll' do
    LL::Parser.new(input).parse
  end

  bench.report 'racc' do
    LL::Bootstrap::Parser.new(input).parse
  end

  bench.compare!
end
