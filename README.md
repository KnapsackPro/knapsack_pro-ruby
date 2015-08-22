# knapsack_pro ruby gem

[![Circle CI](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby.svg)](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby)
[![Gem Version](https://badge.fury.io/rb/knapsack_pro.svg)](https://rubygems.org/gems/knapsack_pro)
[![Code Climate](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/gpa.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)
[![Test Coverage](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/coverage.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)

Knapsack Pro gem splits tests across CI nodes and makes sure that tests will run comparable time on each node. It uses [KnapsackPro.com API](http://docs.knapsackpro.com).

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


Add this line at the bottom of `Rakefile` if your project has it:

```ruby
KnapsackPro.load_tasks if defined?(KnapsackPro)
```

## Usage

You can find here example of rails app with already configured knapsack_pro.

https://github.com/KnapsackPro/rails-app-with-knapsack_pro

### Step for RSpec

Add at the beginning of your `spec_helper.rb`:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::RSpecAdapter.bind
```

### Step for Cucumber

Create file `features/support/knapsack_pro.rb` and add there:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::CucumberAdapter.bind
```

### Step for Minitest

Add at the beginning of your `test_helper.rb`:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

knapsack_pro_adapter = KnapsackPro::Adapters::MinitestAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)
```

### Custom configuration

You can change default Knapsack Pro configuration for RSpec, Cucumber or Minitest tests. Here are examples what you can do. Put below configuration instead of `CUSTOM_CONFIG_GOES_HERE`.

```ruby
# mandatory step
# set test suite token and endpoint url
KnapsackPro::Client::Connection.credentials.set = {
  # token for rspec test suite
  # test suite for cucumber must have different token etc
  test_suite_token: 'xyz',

  # endpoint for production API
  endpoint: 'http://api.knapsackpro.com'
}

# you can use your own logger
require 'logger'
KnapsackPro.logger = Logger.new(STDOUT)
KnapsackPro.logger.level = Logger::INFO
```
