# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knapsack_pro/version'

Gem::Specification.new do |spec|
  spec.name          = "knapsack_pro"
  spec.version       = KnapsackPro::VERSION
  spec.authors       = ["ArturT"]
  spec.email         = ["arturtrzop@gmail.com"]
  spec.summary       = %q{Knapsack Pro splits tests across CI nodes and makes sure that tests will run comparable time on each node.}
  spec.description   = %q{Parallel tests across CI server nodes based on each test file's time execution. It uses KnapsackPro.com API.}
  spec.homepage      = "https://github.com/KnapsackPro/knapsack_pro-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rake', '>= 0'
  spec.add_dependency 'tty-prompt', '~> 0.7'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rspec', '~> 3.0', '>= 2.0.0'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'cucumber', '>= 0'
  spec.add_development_dependency 'spinach', '>= 0.8'
  spec.add_development_dependency 'minitest', '>= 5.0.0'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0'
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'vcr', '~> 2.9'
  spec.add_development_dependency 'webmock', '~> 1.21'
  spec.add_development_dependency 'timecop', '>= 0.1.0'
end
