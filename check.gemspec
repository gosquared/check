#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'check/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Gerhard Lazu"]
  gem.email         = ["gerhard@lazu.co.uk"]
  gem.description   = "Redis backed service for monitoring metric data streams against pre-defined thresholds"
  gem.summary       = "Data stream monitor"
  gem.homepage      = "https://github.com/gosquared/osprey"

  gem.files         = Dir["lib/**/*", "Gemfile", "README.md"]
  gem.test_files    = Dir["test/**/*"]
  gem.name          = "check"
  gem.require_paths = ["lib"]
  gem.version       = Check::VERSION

  gem.add_runtime_dependency "grape", "~> 0.2.1"
  gem.add_runtime_dependency "hashr", "~> 0.0.21"
  gem.add_runtime_dependency "hiredis", "~> 0.4.5"
  gem.add_runtime_dependency "msgpack", "~> 0.4.7"
  gem.add_runtime_dependency "redis", "~> 3.0.1"
  gem.add_runtime_dependency "redis-objects", "~> 0.5.3"
  gem.add_runtime_dependency "unicorn", "~> 4.3.1"
end
