# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logent/version'

Gem::Specification.new do |spec|
  spec.name          = "logent"
  spec.version       = Logent::VERSION
  spec.authors       = ["Uchio KONDO"]
  spec.email         = ["udzura@paperboy.co.jp"]
  spec.description   = %q{Gentle post-to-fluentd log solution}
  spec.summary       = %q{Gentle post-to-fluentd log solution}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluent-logger"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
