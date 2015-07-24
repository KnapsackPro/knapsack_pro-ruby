# knapsack_pro ruby gem

[![Circle CI](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby.svg)](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby)
[![Gem Version](https://badge.fury.io/rb/knapsack_pro.svg)](https://rubygems.org/gems/knapsack_pro)
[![Code Climate](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/gpa.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)
[![Test Coverage](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/coverage.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)

Knapsack Pro gem splits tests across CI nodes and makes sure that tests will run comparable time on each node. It uses KnapsackPro.com API.

The gem supports:

* [RSpec](http://rspec.info)
* [Cucumber](https://cucumber.io)
* [Minitest](http://docs.seattlerb.org/minitest/)
* [Turnip](https://github.com/jnicklas/turnip)

# Basic info

knapsack_pro gem is not ready yet. Please see https://github.com/ArturT/knapsack - it's working version you can use in your project for now.

# Requirements

* >= Ruby 2.0

## Update gem

Please check [changelog](CHANGELOG.md) before update gem. Knapsack Pro follows [semantic versioning](http://semver.org).

## Installation

Add those lines to your application's Gemfile:

```ruby
group :test, :development do
  gem 'knapsack_pro'
end
```

And then execute:

    $ bundle
