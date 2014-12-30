rule '.rb' => '.y' do |task|
  sh "racc -l -o #{task.name} #{task.source}"
end

desc 'Generates the Racc parser for bootstrapping'
task :racc => ['lib/ll/bootstrap/parser.rb']

desc 'Bootstraps the initial parser'
task :bootstrap => [:racc] do
  require_relative '../lib/ll'
  require_relative '../lib/ll/bootstrap/parser'

  path      = File.expand_path('../../lib/ll/parser.rll', __FILE__)
  grammar   = File.read(path)
  parser    = LL::Bootstrap::Parser.new(grammar, path)
  compiler  = LL::Compiler.new
  generator = LL::Generator.new
  ast       = parser.parse

  compiled    = compiler.compile(ast)
  output      = generator.generate(compiled)
  output_path = File.expand_path('../../lib/ll/parser.rb', __FILE__)

  File.open(output_path, 'w') do |file|
    file.write(output)
  end

  puts "Bootstrap parser written to #{output_path}"
end
