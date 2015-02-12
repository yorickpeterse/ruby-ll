desc 'Generates auto-generated files'
task :generate => [:compile, :lexer, :parser]
