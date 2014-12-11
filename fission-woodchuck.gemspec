$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'fission-woodchuck/version'
Gem::Specification.new do |s|
  s.name = 'fission-woodchuck'
  s.version = Fission::Woodchuck::VERSION.version
  s.summary = 'Fission Log Generator'
  s.author = 'Heavywater'
  s.email = 'fission@hw-ops.com'
  s.homepage = 'http://github.com/heavywater/fission-woodchuck'
  s.description = 'Fission Log Generator'
  s.require_path = 'lib'
  s.add_dependency 'fission'
  s.add_dependency 'carnivore-files'
  s.files = Dir['{lib}/**/**/*'] + %w(fission-woodchuck.gemspec README.md CHANGELOG.md)
end
