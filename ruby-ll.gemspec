require File.expand_path('../lib/ll/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ruby-ll'
  s.version     = LL::VERSION
  s.authors     = ['Yorick Peterse']
  s.email       = 'yorickpeterse@gmail.com'
  s.summary     = 'An LL(1) parser generator for Ruby.'
  s.homepage    = 'https://github.com/yorickpeterse/ruby-ll'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = Dir.glob([
    'checkum/**/*',
    'doc/**/*',
    'lib/**/*.rb',
    'ext/**/*',
    'README.md',
    'LICENSE',
    '*.gemspec',
    '.yardopts'
  ]).select { |path| File.file?(path) }

  s.executables = ['ruby-ll']

  if RUBY_PLATFORM == 'java'
    s.files << 'lib/ll.jar'

    s.platform = 'java'
  else
    s.extensions = ['ext/c/extconf.rb']
  end

  s.has_rdoc              = 'yard'
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'ast'
  s.add_dependency 'ansi'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', ['~> 3.0']
  s.add_development_dependency 'yard'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'kramdown'
  s.add_development_dependency 'benchmark-ips', '~> 2.0'
  s.add_development_dependency 'rake-compiler'
end
