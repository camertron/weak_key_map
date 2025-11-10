$:.unshift File.join(File.dirname(__FILE__), "lib")
require "weak_key_map/version"

Gem::Specification.new do |s|
  s.name     = "weak_key_map"
  s.version  = ::WeakKeyMap::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron/weak_key_map"
  s.description = s.summary = "A backport of ObjectSpace::WeakKeyMap for Ruby < 3.3"
  s.platform = Gem::Platform::RUBY

  s.require_path = "lib"

  s.files = Dir["{lib,test}/**/*", "Gemfile", "LICENSE", "CHANGELOG.md", "README.md", "Rakefile", "weak_key_map.gemspec"]
end
