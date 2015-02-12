require_relative '../benchmark_helper'

input = File.read(File.expand_path('../../lib/ll/parser.rll', __FILE__))

Benchmark.ips do |bench|
  bench.report 'ruby-ll' do
    LL::Parser.new(input).parse
  end

  bench.report 'racc' do
    LL::Bootstrap::Parser.new(input).parse
  end

  bench.compare!
end
