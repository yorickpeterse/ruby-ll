require_relative '../benchmark_helper'

Benchmark.ips do |bench|
  bench.report 'ruby-ll' do
    LL::BenchmarkParser::JSONLL.new.parse
  end

  bench.report 'racc' do
    LL::BenchmarkParser::JSONRacc.new.parse
  end

  bench.compare!
end
