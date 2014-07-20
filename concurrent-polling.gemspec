# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'concurrent/polling/version'

Gem::Specification.new do |spec|
  spec.name          = "concurrent-polling"
  spec.version       = Concurrent::Polling::VERSION
  spec.authors       = ["Frank Falkenberg"]
  spec.email         = ["faltibrain@gmail.com"]
  spec.summary       = %q{Concurrency based polling.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", '~> 0.6.1'
  spec.add_dependency "values", '~> 1.5'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake"
end
