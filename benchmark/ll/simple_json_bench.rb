require_relative '../benchmark_helper'

Benchmark.ips do |bench|
  bench.report 'ruby-ll' do
    LL::BenchmarkParser::JSON.new.parse
  end
end
