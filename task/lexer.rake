rule '.rb' => '.rl' do |task|
  sh "ragel -F1 -R #{task.source} -o #{task.name}"

  input  = File.read(task.source)
  output = File.read(task.name)
  getkey = input.match(/getkey\s+(.+);/)[1]

  output = output.gsub(getkey, '_wide')
  output = output.gsub('_trans = if', "_wide = #{getkey}\n  _trans = if")

  File.open(task.name, 'w') do |handle|
    handle.write(output)
  end
end

desc 'Generates the lexers'
multitask :lexer => []
