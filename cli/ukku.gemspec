# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','ukku','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'ukku'
  s.version = Ukku::VERSION
  s.author = 'Germán Escobar'
  s.email = 'german.escobarc@gmail.com'
  s.homepage = 'http://germanescobar.net/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Easily deploy your application to your own server using "git push"'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'ukku'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_runtime_dependency('gli','2.12.2')
  s.add_runtime_dependency('docopt', '0.5.0')
  s.add_runtime_dependency('rye', '0.9')
  s.add_runtime_dependency('rugged', '0.21.3')
end
