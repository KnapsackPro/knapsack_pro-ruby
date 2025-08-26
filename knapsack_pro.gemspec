require_relative "lib/knapsack_pro/version"

Gem::Specification.new do |spec|
  spec.name          = "knapsack_pro"
  spec.version       = KnapsackPro::VERSION
  spec.required_ruby_version = '>= 3.0.0'
  spec.authors       = ["ArturT"]
  spec.email         = ["support@knapsackpro.com"]
  spec.summary       = "Knapsack Pro splits tests across parallel CI nodes and ensures each parallel job finish work at a similar time."
  spec.description   = "Knapsack Pro wraps your current test runner(s) and works with your existing CI infrastructure to parallelize tests optimally. It dynamically splits your tests based on up-to-date test execution data. It's designed from the ground up for CI and supports all of them."
  spec.homepage      = "https://knapsackpro.com"
  spec.license       = "MIT"

  spec.metadata["bug_tracker_uri"] = "https://github.com/KnapsackPro/knapsack_pro-ruby/issues"
  spec.metadata["changelog_uri"] = "https://github.com/KnapsackPro/knapsack_pro-ruby/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://docs.knapsackpro.com/knapsack_pro-ruby/guide/"
  spec.metadata["homepage_uri"] = "https://knapsackpro.com"
  spec.metadata["source_code_uri"] = "https://github.com/KnapsackPro/knapsack_pro-ruby"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*") + Dir.glob("exe/*")
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rake", ">= 0"
  spec.add_dependency "thor", "~> 1.4"

  spec.add_development_dependency "bundler", ">= 1.6"
  spec.add_development_dependency "cucumber", ">= 0"
  spec.add_development_dependency "minitest", ">= 5.0.0"
  spec.add_development_dependency "ostruct", ">= 0.6.0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.3"
  spec.add_development_dependency "spinach", ">= 0.8"
  spec.add_development_dependency "test-unit", ">= 3.0.0"
  spec.add_development_dependency "timecop", ">= 0.9.9"
  spec.add_development_dependency "vcr", ">= 6.0"
  spec.add_development_dependency "webmock", ">= 3.13"
end
