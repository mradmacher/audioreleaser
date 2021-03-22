$: << File.expand_path('lib', __dir__)


Gem::Specification.new do |s|
  s.name = 'audiofeeler'
  s.version = '0.0.1'
  s.summary = 'Audio helper library for artists.'
  s.description = ''
  s.authors = ['Michał Radmacher']

  s.email = ['michal@radmacher.pl']
  s.extra_rdoc_files = ['README.md']
  s.files = Dir.glob('{lib}/**/*') + %w[README.md]
  s.test_files = Dir['spec/**/*']
  s.homepage = 'https://github.com/mradmacher/audiofeeler'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.5.1'
  s.rdoc_options = ['--main']
  s.require_paths = ['lib']

  s.add_dependency 'taglib-ruby'
  s.add_dependency 'shell_whisperer'
  s.add_development_dependency 'rubocop'
end
