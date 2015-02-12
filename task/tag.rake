desc 'Creates a Git tag for the current version'
task :tag do
  version = GEMSPEC.version.to_s

  sh %Q{git tag -a -m "Version #{version}" v#{version}}
end
