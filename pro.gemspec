# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pro/version'

Gem::Specification.new do |spec|
  spec.name          = "pro"
  spec.version       = Pro::VERSION
  spec.authors       = ["Tristan Hume"]
  spec.email         = ["tris.hume@gmail.com"]
  spec.description   = %q{Lightweight git project tool.}
  spec.summary       = %q{Command line tool that allows you to quickly cd to git projects and other handy things.}
  spec.homepage      = "http://github.com/trishume/pro"
  spec.license       = "MIT"

  #spec.add_runtime_dependency 'commander','~> 4.1.2'  
  spec.add_runtime_dependency 'fuzzy_match'
  spec.add_runtime_dependency 'colored'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
