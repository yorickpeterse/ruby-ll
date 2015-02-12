rule '.rb' => '.rll' do |task|
  sh "./bin/ruby-ll #{task.source} -o #{task.name} --no-requires"
end

desc 'Generates the parsers'
task :parser => ['lib/ll/parser.rb']

desc 'Generates the benchmark parsers'
task :bench_parser => ['benchmark/parsers/ll/json.rb']
