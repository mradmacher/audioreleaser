$: << File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name = 'audioreleaser'
  s.version = '0.0.1'
  s.summary = 'Convert and tag audio albums.'
  s.description = ''
  s.authors = ['Michał Radmacher']

  s.email = ['michal@radmacher.pl']
  s.extra_rdoc_files = ['README.md']
  s.files = Dir.glob('{lib}/**/*') + %w[README.md]
  s.test_files = Dir['spec/**/*']
  s.homepage = 'https://github.com/mradmacher/audioreleaser'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 3.3.5'
  s.rdoc_options = ['--main']
  s.require_paths = ['lib']

  s.add_dependency 'taglib-ruby', '~> 1.1.3'
  s.add_dependency 'shell_whisperer'
  s.add_development_dependency 'rubocop', '~> 1.67'
end
