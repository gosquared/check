#!/usr/bin/env gem build
# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'check'
  gem.version       = '0.2.1'
  gem.authors       = ['Gerhard Lazu']
  gem.email         = ['gerhard@lazu.co.uk']
  gem.description   = 'Redis backed service for monitoring metric data streams against pre-defined thresholds'
  gem.summary       = 'Data stream monitor'
  gem.homepage      = 'https://github.com/gosquared/osprey'

  gem.files         = Dir['lib/**/*', 'examples/**/*', 'benchmarks/**/*', 'Gemfile', 'check.gemspec', 'Rakefile', 'README.md', 'LICENSE']
  gem.executables   = Dir['bin/*']
  gem.test_files    = Dir['test/**/*']
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'hashr', '~> 0.0.21'
  gem.add_runtime_dependency 'hiredis', '~> 0.4.5'
  gem.add_runtime_dependency 'json', '~> 1.7.5'
  gem.add_runtime_dependency 'redis', '~> 3.0.2'
  gem.add_runtime_dependency 'redis-objects', '~> 0.6.1'

  ## API
  gem.add_runtime_dependency 'grape', '~> 0.2.2'
  gem.add_runtime_dependency 'grape-swagger', '~> 0.3.0'
end
