$: << File.expand_path("../lib", __FILE__)
require "matcher/version"

Gem::Specification.new do |gem|

  gem.name = "xmatch"
  gem.summary = "A Ruby library for comparing XML documents and reporting on mismatches"
  gem.homepage = "http://github.com/pmoran/xmatch"
  gem.authors = ["Peter Moran"]
  gem.email = "workingpeter@gmail.com"

  gem.version = Representative::VERSION.dup
  gem.platform = Gem::Platform::RUBY
  gem.add_runtime_dependency("nokogiri", "~> 1.4.2")

  gem.add_development_dependency("bundler", "~> 1.0")
  gem.add_development_dependency("rspec", "~> 1.3.0")

  gem.require_path = "lib"
  gem.files = Dir["lib/**/*", "examples/**/*", "README.markdown", "LICENSE"]
  gem.test_files = Dir["spec/**/*", "Rakefile"]

end