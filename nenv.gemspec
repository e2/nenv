# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nenv/version'

Gem::Specification.new do |spec|
  spec.name          = "nenv"
  spec.version       = Nenv::VERSION
  spec.authors       = ["Cezary Baginski"]
  spec.email         = ["cezary@chronomantic.net"]
  spec.summary       = %q{Convenience wrapper for Ruby's ENV}
  spec.description   = %q{Using ENV is like using raw SQL statements in your code. Well all know how that ends...}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "rake", "~> 10.0"
end
