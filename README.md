# knapsack_pro ruby gem

[![Circle CI](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby.svg)](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby)
[![Gem Version](https://badge.fury.io/rb/knapsack_pro.svg)](https://rubygems.org/gems/knapsack_pro)
[![Code Climate](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/gpa.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)
[![Test Coverage](https://codeclimate.com/github/KnapsackPro/knapsack-pro-ruby/badges/coverage.svg)](https://codeclimate.com/github/KnapsackPro/knapsack-pro-ruby/coverage)

Follow us on [Twitter @KnapsackPro](https://twitter.com/KnapsackPro) and give Like on [Facebook KnapsackPro](https://www.facebook.com/KnapsackPro)

Knapsack Pro gem splits tests across CI nodes and makes sure that tests will run comparable time on each node. It uses [KnapsackPro.com API](http://docs.knapsackpro.com). You can learn more at [https://knapsackpro.com](https://knapsackpro.com?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=learn_more)

The knapsack_pro gem supports:

* [RSpec](http://rspec.info)
* [Cucumber](https://cucumber.io)
* [Minitest](http://docs.seattlerb.org/minitest/)
* [test-unit](https://github.com/test-unit/test-unit)
* [Spinach](https://github.com/codegram/spinach)
* [Turnip](https://github.com/jnicklas/turnip)

__Would you like to try knapsack_pro gem?__ You can [get an API token here](http://knapsackpro.com?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=get_api_token).

# How does knapsack_pro work?

## Basics

Basically it will track your branches, commits and for how many CI nodes you are running tests.
Collected data about test time execution will be sent to the API where the test suite split is done.
The next time you run your tests, each CI node will get an appropriate set of test files in order to achieve comparable time execution on each CI node.

## Details

For instance when you run tests with `rake knapsack_pro:rspec`:

* information about all your existing test files are sent to API http://docs.knapsackpro.com/api/v1/#build_distributions_subset_post
* the API returns which files should be executed on a particular CI node (example KNAPSACK_PRO_CI_NODE_INDEX=0)
* if the API server has data about previous test runs then it will use this to return more accurate test split results, otherwise the API returns a simple split based on directory names
* knapsack_pro will run the set of test files which it got from API
* once tests are finished, knapsack_pro will send information about time execution of each file to API http://docs.knapsackpro.com/api/v1/#build_subsets_post so data can be used for future test runs

The knapsack_pro has also [queue mode](#queue-mode) to get an optimal test suite split.

## FAQ

__NEW:__ Up to date [FAQ for knapsack_pro gem can be found here](https://knapsackpro.com/faq/knapsack_pro_client/knapsack_pro_ruby).

__OLD:__ This README also contains FAQ questions but we keep adding new info only to our new FAQ page mentioned above.

We keep this old FAQ in README to not break old links spread across the web. You can see old FAQ list of questions for common problems and tips in below [Table of Contents](#table-of-contents). Scroll 1 page down and you will see the FAQ in the table of contents.

# Requirements

`>= Ruby 2.1.0`

# Table of Contents

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Update gem](#update-gem)
- [Installation](#installation)
- [How to set up](#how-to-set-up)
  - [Usage (How to set up 1 of 3)](#usage-how-to-set-up-1-of-3)
    - [Step for RSpec](#step-for-rspec)
    - [Step for Cucumber](#step-for-cucumber)
    - [Step for Minitest](#step-for-minitest)
    - [Step for test-unit](#step-for-test-unit)
    - [Step for Spinach](#step-for-spinach)
    - [Custom configuration](#custom-configuration)
  - [Setup your CI server (How to set up 2 of 3)](#setup-your-ci-server-how-to-set-up-2-of-3)
    - [Set API key token](#set-api-key-token)
    - [Set knapsack_pro command to execute tests](#set-knapsack_pro-command-to-execute-tests)
  - [Repository adapter (How to set up 3 of 3)](#repository-adapter-how-to-set-up-3-of-3)
    - [By default `KNAPSACK_PRO_REPOSITORY_ADAPTER` environment variable is undefined](#by-default-knapsack_pro_repository_adapter-environment-variable-is-undefined)
    - [When should you set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER=git` (when CI provider is not supported and you use git)](#when-should-you-set-global-variable-knapsack_pro_repository_adaptergit-when-ci-provider-is-not-supported-and-you-use-git)
    - [When you don't use git](#when-you-dont-use-git)
- [Queue Mode](#queue-mode)
  - [How does queue mode work?](#how-does-queue-mode-work)
  - [How to use queue mode?](#how-to-use-queue-mode)
  - [Additional info about queue mode](#additional-info-about-queue-mode)
  - [Extra configuration for Queue Mode](#extra-configuration-for-queue-mode)
    - [KNAPSACK_PRO_FIXED_QUEUE_SPLIT (remember queue split on retry CI node)](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node)
    - [KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS (hide duplicated summary of pending and failed tests)](#knapsack_pro_modify_default_rspec_formatters-hide-duplicated-summary-of-pending-and-failed-tests)
  - [Supported test runners in queue mode](#supported-test-runners-in-queue-mode)
- [Split test files by test cases](#split-test-files-by-test-cases)
  - [RSpec split test files by test examples (by individual `it`s)](#rspec-split-test-files-by-test-examples-by-individual-its)
    - [Why I see error: Don't know how to build task 'knapsack_pro:rspec_test_example_detector'?](#why-i-see-error-dont-know-how-to-build-task-knapsack_prorspec_test_example_detector)
  - [How to manually define a list of slow test files to be split by test cases](#how-to-manually-define-a-list-of-slow-test-files-to-be-split-by-test-cases)
- [Extra configuration for CI server](#extra-configuration-for-ci-server)
  - [Info about ENV variables](#info-about-env-variables)
    - [KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT (test suite split based on seed)](#knapsack_pro_fixed_test_suite_split-test-suite-split-based-on-seed)
    - [Environment variables for debugging gem](#environment-variables-for-debugging-gem)
  - [Required CI configuration if you use retry single failed CI node feature on your CI server when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true (in Queue Mode) or KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true (in Regular Mode)](#required-ci-configuration-if-you-use-retry-single-failed-ci-node-feature-on-your-ci-server-when-knapsack_pro_fixed_queue_splittrue-in-queue-mode-or-knapsack_pro_fixed_test_suite_splittrue-in-regular-mode)
  - [Passing arguments to rake task](#passing-arguments-to-rake-task)
    - [Passing arguments to rspec](#passing-arguments-to-rspec)
    - [Passing arguments to cucumber](#passing-arguments-to-cucumber)
    - [Passing arguments to minitest](#passing-arguments-to-minitest)
    - [Passing arguments to test-unit](#passing-arguments-to-test-unit)
    - [Passing arguments to spinach](#passing-arguments-to-spinach)
  - [Knapsack Pro binary](#knapsack-pro-binary)
  - [Test file names encryption](#test-file-names-encryption)
    - [How to enable test file names encryption?](#how-to-enable-test-file-names-encryption)
    - [How to debug test file names?](#how-to-debug-test-file-names)
      - [Preview encrypted RSpec test example paths?](#preview-encrypted-rspec-test-example-paths)
    - [How to enable branch names encryption?](#how-to-enable-branch-names-encryption)
    - [How to debug branch names?](#how-to-debug-branch-names)
  - [Supported CI providers](#supported-ci-providers)
    - [Info for CircleCI users](#info-for-circleci-users)
      - [CircleCI and knapsack_pro Queue Mode](#circleci-and-knapsack_pro-queue-mode)
    - [Info for Travis users](#info-for-travis-users)
    - [Info for semaphoreci.com users](#info-for-semaphorecicom-users)
      - [Semaphore 2.0](#semaphore-20)
      - [Semaphore 1.0](#semaphore-10)
    - [Info for buildkite.com users](#info-for-buildkitecom-users)
    - [Info for GitLab CI users](#info-for-gitlab-ci-users)
      - [GitLab CI `>= 11.5`](#gitlab-ci--115)
      - [GitLab CI `< 11.5` (old GitLab CI)](#gitlab-ci--115-old-gitlab-ci)
    - [Info for codeship.com users](#info-for-codeshipcom-users)
    - [Info for Heroku CI users](#info-for-heroku-ci-users)
    - [Info for Solano CI users](#info-for-solano-ci-users)
    - [Info for AppVeyor users](#info-for-appveyor-users)
    - [Info for snap-ci.com users](#info-for-snap-cicom-users)
    - [Info for cirrus-ci.org users](#info-for-cirrus-ciorg-users)
    - [Info for Jenkins users](#info-for-jenkins-users)
    - [Info for GitHub Actions users](#info-for-github-actions-users)
    - [Info for Codefresh.io users](#info-for-codefreshio-users)
- [FAQ](#faq)
  - [Common problems](#common-problems)
    - [Why I see API error commit_hash parameter is required?](#why-i-see-api-error-commit_hash-parameter-is-required)
    - [Why I see `LoadError: cannot load such file -- spec_helper`?](#why-i-see-loaderror-cannot-load-such-file----spec_helper)
    - [Why my CI build fails when I use Test::Unit even when all tests passed?](#why-my-ci-build-fails-when-i-use-testunit-even-when-all-tests-passed)
    - [Why I see HEAD as branch name in user dashboard for Build metrics for my API token?](#why-i-see-head-as-branch-name-in-user-dashboard-for-build-metrics-for-my-api-token)
    - [Why Capybara feature tests randomly fail when using CI parallelisation?](#why-capybara-feature-tests-randomly-fail-when-using-ci-parallelisation)
    - [Why knapsack_pro freezes / hangs my CI (for instance Travis)?](#why-knapsack_pro-freezes--hangs-my-ci-for-instance-travis)
    - [Why tests hitting external API fail?](#why-tests-hitting-external-api-fail)
    - [Why green test suite for Cucumber 2.99 tests always fails with `invalid option: --require`?](#why-green-test-suite-for-cucumber-299-tests-always-fails-with-invalid-option---require)
    - [Queue Mode problems](#queue-mode-problems)
      - [Why when I use Queue Mode for RSpec then my tests fail?](#why-when-i-use-queue-mode-for-rspec-then-my-tests-fail)
      - [Why when I use Queue Mode for RSpec then FactoryBot/FactoryGirl tests fail?](#why-when-i-use-queue-mode-for-rspec-then-factorybotfactorygirl-tests-fail)
      - [Why when I use Queue Mode for RSpec then my rake tasks are run twice?](#why-when-i-use-queue-mode-for-rspec-then-my-rake-tasks-are-run-twice)
      - [Why when I use Queue Mode for RSpec then I see error `superclass mismatch for class`?](#why-when-i-use-queue-mode-for-rspec-then-i-see-error-superclass-mismatch-for-class)
      - [Why when I use Queue Mode for RSpec then `.rspec` config is ignored?](#why-when-i-use-queue-mode-for-rspec-then-rspec-config-is-ignored)
      - [Why I don't see collected time execution data for my build in user dashboard?](#why-i-dont-see-collected-time-execution-data-for-my-build-in-user-dashboard)
      - [Why all test files have 0.1s time execution for my CI build in user dashboard?](#why-all-test-files-have-01s-time-execution-for-my-ci-build-in-user-dashboard)
      - [Why when I use Queue Mode for RSpec and test fails then I see multiple times info about failed test in RSpec result?](#why-when-i-use-queue-mode-for-rspec-and-test-fails-then-i-see-multiple-times-info-about-failed-test-in-rspec-result)
      - [Why when I use Queue Mode for RSpec then I see multiple times the same pending tests?](#why-when-i-use-queue-mode-for-rspec-then-i-see-multiple-times-the-same-pending-tests)
      - [Does in Queue Mode the RSpec is initialized many times that causes Rails load over and over again?](#does-in-queue-mode-the-rspec-is-initialized-many-times-that-causes-rails-load-over-and-over-again)
      - [Why my tests are executed twice in queue mode? Why CI node runs whole test suite again?](#why-my-tests-are-executed-twice-in-queue-mode-why-ci-node-runs-whole-test-suite-again)
      - [How to fix capybara-screenshot fail with `SystemStackError: stack level too deep` when using Queue Mode for RSpec?](#how-to-fix-capybara-screenshot-fail-with-systemstackerror-stack-level-too-deep-when-using-queue-mode-for-rspec)
      - [Parallel tests Cucumber and RSpec with Cucumber failures exit CI node early leaving fewer CI nodes to finish RSpec Queue.](#parallel-tests-cucumber-and-rspec-with-cucumber-failures-exit-ci-node-early-leaving-fewer-ci-nodes-to-finish-rspec-queue)
      - [Why when I reran the same build (same commit hash, etc) on Codeship then no tests would get executed in Queue Mode?](#why-when-i-reran-the-same-build-same-commit-hash-etc-on-codeship-then-no-tests-would-get-executed-in-queue-mode)
      - [Why knapsack_pro hangs / freezes / is stale i.e. for Codeship in Queue Mode?](#why-knapsack_pro-hangs--freezes--is-stale-ie-for-codeship-in-queue-mode)
      - [How to find seed in RSpec output when I use Queue Mode for RSpec?](#how-to-find-seed-in-rspec-output-when-i-use-queue-mode-for-rspec)
      - [How to configure puffing-billy gem with Knapsack Pro Queue Mode?](#how-to-configure-puffing-billy-gem-with-knapsack-pro-queue-mode)
  - [General questions](#general-questions)
    - [How to run tests for particular CI node in your development environment](#how-to-run-tests-for-particular-ci-node-in-your-development-environment)
      - [for knapsack_pro regular mode](#for-knapsack_pro-regular-mode)
      - [for knapsack_pro queue mode](#for-knapsack_pro-queue-mode)
    - [What happens when Knapsack Pro API is not available/not reachable temporarily?](#what-happens-when-knapsack-pro-api-is-not-availablenot-reachable-temporarily)
      - [for knapsack_pro regular mode](#for-knapsack_pro-regular-mode-1)
      - [for knapsack_pro queue mode](#for-knapsack_pro-queue-mode-1)
    - [How can I change log level?](#how-can-i-change-log-level)
    - [How to write knapsack_pro logs to a file?](#how-to-write-knapsack_pro-logs-to-a-file)
      - [set directory where to write log file (option 1 - recommended)](#set-directory-where-to-write-log-file-option-1---recommended)
      - [set custom logger config (option 2)](#set-custom-logger-config-option-2)
      - [How to preserve logs on my CI after CI build completed?](#how-to-preserve-logs-on-my-ci-after-ci-build-completed)
    - [How to split tests based on test level instead of test file level?](#how-to-split-tests-based-on-test-level-instead-of-test-file-level)
      - [A. Create multiple small test files](#a-create-multiple-small-test-files)
      - [B. Use tags to mark set of tests in particular test file](#b-use-tags-to-mark-set-of-tests-in-particular-test-file)
    - [How to make knapsack_pro works for forked repositories of my project?](#how-to-make-knapsack_pro-works-for-forked-repositories-of-my-project)
    - [How to use junit formatter?](#how-to-use-junit-formatter)
      - [How to use junit formatter with knapsack_pro regular mode?](#how-to-use-junit-formatter-with-knapsack_pro-regular-mode)
      - [How to use junit formatter with knapsack_pro queue mode?](#how-to-use-junit-formatter-with-knapsack_pro-queue-mode)
        - [How to use junit formatter with knapsack_pro queue mode when CI nodes use common local drive?](#how-to-use-junit-formatter-with-knapsack_pro-queue-mode-when-ci-nodes-use-common-local-drive)
        - [Why `tmp/rspec_final_results.xml` is corrupted when I use junit formatter with knapsack_pro queue mode?](#why-tmprspec_final_resultsxml-is-corrupted-when-i-use-junit-formatter-with-knapsack_pro-queue-mode)
        - [How to use junit formatter with knapsack_pro queue mode in Cucumber?](#how-to-use-junit-formatter-with-knapsack_pro-queue-mode-in-cucumber)
    - [How to use JSON formatter for RSpec?](#how-to-use-json-formatter-for-rspec)
      - [How to use RSpec JSON formatter with knapsack_pro Queue Mode?](#how-to-use-rspec-json-formatter-with-knapsack_pro-queue-mode)
        - [How to use RSpec JSON formatter with knapsack_pro Queue Mode when CI nodes use common local drive?](#how-to-use-rspec-json-formatter-with-knapsack_pro-queue-mode-when-ci-nodes-use-common-local-drive)
    - [How many API keys I need?](#how-many-api-keys-i-need)
    - [What is optimal order of test commands?](#what-is-optimal-order-of-test-commands)
    - [How to set `before(:suite)` and `after(:suite)` RSpec hooks in Queue Mode (Percy.io example)?](#how-to-set-beforesuite-and-aftersuite-rspec-hooks-in-queue-mode-percyio-example)
      - [percy-capybara gem version < 4 (old)](#percy-capybara-gem-version--4-old)
      - [percy-capybara gem version >= 4](#percy-capybara-gem-version--4)
    - [How to call `before(:suite)` and `after(:suite)` RSpec hooks only once in Queue Mode?](#how-to-call-beforesuite-and-aftersuite-rspec-hooks-only-once-in-queue-mode)
    - [What hooks are supported in Queue Mode?](#what-hooks-are-supported-in-queue-mode)
    - [How to run knapsack_pro with parallel_tests gem?](#how-to-run-knapsack_pro-with-parallel_tests-gem)
      - [Should I use parallel_tests gem (what are pitfalls)?](#should-i-use-parallel_tests-gem-what-are-pitfalls)
      - [parallel_tests with knapsack_pro on parallel CI nodes](#parallel_tests-with-knapsack_pro-on-parallel-ci-nodes)
      - [parallel_tests with knapsack_pro on single CI machine](#parallel_tests-with-knapsack_pro-on-single-ci-machine)
    - [How to retry failed tests (flaky tests)?](#how-to-retry-failed-tests-flaky-tests)
    - [How can I run tests from multiple directories?](#how-can-i-run-tests-from-multiple-directories)
    - [Why I don't see all test files being recorded in user dashboard](#why-i-dont-see-all-test-files-being-recorded-in-user-dashboard)
    - [Why when I use 2 different CI providers then not all test files are executed?](#why-when-i-use-2-different-ci-providers-then-not-all-test-files-are-executed)
    - [How to run only RSpec feature tests or non feature tests?](#how-to-run-only-rspec-feature-tests-or-non-feature-tests)
    - [How to exclude tests from running them?](#how-to-exclude-tests-from-running-them)
    - [How to run a specific list of test files or only some tests from test file?](#how-to-run-a-specific-list-of-test-files-or-only-some-tests-from-test-file)
    - [How to run knapsack_pro only on a few parallel CI nodes instead of all?](#how-to-run-knapsack_pro-only-on-a-few-parallel-ci-nodes-instead-of-all)
    - [How to use CodeClimate with knapsack_pro?](#how-to-use-codeclimate-with-knapsack_pro)
    - [How to use simplecov in Queue Mode?](#how-to-use-simplecov-in-queue-mode)
    - [Do I need to use separate API token for Queue Mode and Regular Mode?](#do-i-need-to-use-separate-api-token-for-queue-mode-and-regular-mode)
    - [How to stop running tests on the first failed test (fail fast tests in RSpec)?](#how-to-stop-running-tests-on-the-first-failed-test-fail-fast-tests-in-rspec)
  - [Questions around data usage and security](#questions-around-data-usage-and-security)
    - [What data is sent to your servers?](#what-data-is-sent-to-your-servers)
    - [How is that data secured?](#how-is-that-data-secured)
    - [Who has access to the data?](#who-has-access-to-the-data)
- [Gem tests](#gem-tests)
  - [Spec](#spec)
- [Contributing](#contributing)
  - [Publishing](#publishing)
- [Mentions](#mentions)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Update gem

Please check [changelog](CHANGELOG.md) before updating gem. Knapsack Pro follows [semantic versioning](http://semver.org).

## Installation

Add these lines to your application's Gemfile:

```ruby
group :test, :development do
  gem 'knapsack_pro'
end
```

And then execute:

```bash
bundle install
```

If you are not using Rails then add this line at the bottom of `Rakefile`:

```ruby
# Add this only if you are not using Rails.
# If you use Rails then knapsack_pro rake tasks are already loaded
# so there is no need to explicitly load them.
KnapsackPro.load_tasks if defined?(KnapsackPro)
```

__Please check [online installation guide](http://docs.knapsackpro.com/knapsack_pro-ruby/guide/#questions) to get started.__ It will ask you a few questions and generate instruction steps for your project.

_You only need to read the next section if you want to understand optional gem configuration and features._

## How to set up

If you use [VCR](https://github.com/vcr/vcr), [WebMock](https://github.com/bblimke/webmock) or [FakeWeb](https://github.com/chrisk/fakeweb) gems then you need to allow them to make requests to the Knapsack Pro API.

For VCR add Knapsack Pro API subdomain to [ignore hosts](https://www.relishapp.com/vcr/vcr/v/2-9-3/docs/configuration/ignore-request):

```ruby
# spec/spec_helper.rb or wherever your VCR configuration is

require 'vcr'
VCR.configure do |config|
  config.hook_into :webmock # or :fakeweb
  config.ignore_hosts('localhost', '127.0.0.1', '0.0.0.0', 'api.knapsackpro.com')
end

# add below when you hook into webmock
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true, allow: ['api.knapsackpro.com'])

# add below when you use FakeWeb
require 'fakeweb'
FakeWeb.allow_net_connect = %r[^https?://api\.knapsackpro\.com]
```

Ensure you have `require false` in your Gemfile for webmock gem (see below) when VCR is hooked into it. That ensures that the webmock configuration in `spec_helper.rb` (above) is loaded properly.

```ruby
# Gemfile
group :test do
  gem 'vcr'
  gem 'webmock', require: false
  gem 'fakeweb', require: false # example when you use fakeweb
end
```

If you happen to see your tests failing due to WebMock not allowing requests to Knapsack Pro API it means you probably reconfigure WebMock in some of your tests.
For instance, you may use `WebMock.reset!` or it's called automatically in `after(:each)` block, if you `require 'webmock/rspec'` ([more about the issue](https://github.com/bblimke/webmock/issues/484#issuecomment-116193449)). It will remove api.knapsackpro.com from whitelisted domains. Please try below:

```ruby
RSpec.configure do |config|
  config.after(:suite) do
    WebMock.disable_net_connect!(
      allow_localhost: true,
      allow: [
        'api.knapsackpro.com',
      ],
    )
  end
end
```

### Usage (How to set up 1 of 3)

__Tip:__ You can find here an example of a rails app with knapsack_pro already configured.

https://github.com/KnapsackPro/rails-app-with-knapsack_pro

#### Step for RSpec

Add at the beginning of your `spec_helper.rb`:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::RSpecAdapter.bind
```

#### Step for Cucumber

Create file `features/support/knapsack_pro.rb` and add there:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::CucumberAdapter.bind
```

#### Step for Minitest

Add at the beginning of your `test_helper.rb`:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

knapsack_pro_adapter = KnapsackPro::Adapters::MinitestAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)
```

#### Step for test-unit

Add at the beginning of your `test_helper.rb`:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

knapsack_pro_adapter = KnapsackPro::Adapters::TestUnitAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)
```

#### Step for Spinach

Create file `features/support/knapsack_pro.rb` and add there:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::SpinachAdapter.bind
```

#### Custom configuration

You can change the default Knapsack Pro configuration for RSpec, Cucumber, Minitest, test-unit or Spinach tests. Here are examples what you can do. Put the configuration below in place of `CUSTOM_CONFIG_GOES_HERE` (in the configuration samples above).

```ruby
# you can use your own logger
require 'logger'
KnapsackPro.logger = Logger.new(STDOUT)
KnapsackPro.logger.level = Logger::DEBUG
```

Debug is default log level and it is recommended. [Read more](#how-can-i-change-log-level).

Note your own logger is configured in `spec_helper.rb` or `rails_helper.rb` and it will start working when those files will be loaded.
It means the very first request to Knapsack Pro API will be log to `STDOUT` using logger built into knapsack_pro instead of your custom logger.

If you want to change log level globally than just for your custom log level, please [see this](#how-can-i-change-log-level).

### Setup your CI server (How to set up 2 of 3)

#### Set API key token

Set one or more tokens depending on how many test suites you run on CI server.

* `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` - as value set token for rspec test suite. Token can be generated when you sign in to [knapsackpro.com](http://www.knapsackpro.com).
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER` - token for cucumber test suite.
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST` - token for minitest test suite.
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT` - token for test-unit test suite.
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH` - token for spinach test suite.

__Tip:__ In case you have for instance multiple rspec test suites then prepend each of knapsack_pro command which executes tests with `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` variable.

#### Set knapsack_pro command to execute tests

On your CI server run this command for the first CI node. Update `KNAPSACK_PRO_CI_NODE_INDEX` for the next one.

```bash
# Step for RSpec
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec

# Step for Cucumber
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

# Step for Minitest
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest

# Step for test-unit
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:test_unit

# Step for Spinach
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach
```

You can add `KNAPSACK_PRO_TEST_FILE_PATTERN` if your tests are not in default directory. For instance:

```bash
# Step for RSpec
KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_specs/**{,/*/**}/*_spec.rb" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec

# Step for Cucumber
KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_features/**{,/*/**}/*.feature" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

# Step for Minitest
KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_tests/**{,/*/**}/*_test.rb" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest

# Step for test-unit
KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_tests/**{,/*/**}/*_test.rb" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:test_unit

# Step for Spinach
KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_features/**{,/*/**}/*.feature" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach
```

__Tip:__ If you use one of the supported CI providers then instead of the above steps you should [take a look at this](#supported-ci-providers).

__Tip 2:__ If you use one of unsupported CI providers ([here is list of supported CI providers](#supported-ci-providers)) then you should [set KNAPSACK_PRO_REPOSITORY_ADAPTER=git](#when-should-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported).

### Repository adapter (How to set up 3 of 3)

#### By default `KNAPSACK_PRO_REPOSITORY_ADAPTER` environment variable is undefined

By default `KNAPSACK_PRO_REPOSITORY_ADAPTER` variable has no value so knapsack_pro will try to get info about branch name and commit hash from [supported CI](#supported-ci-providers) (CI providers have branch, commit, project directory stored as environment variables). In case when you use other CI provider like Jenkins then please set below variables on your own.

`KNAPSACK_PRO_BRANCH` - It's branch name. You run tests on this branch.

`KNAPSACK_PRO_COMMIT_HASH` - Commit hash. You run tests for this commit.

You can also use git as repository adapter to determine branch and commit hash, please see below section.

#### When should you set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER=git` (when CI provider is not supported and you use git)

`KNAPSACK_PRO_REPOSITORY_ADAPTER` - When it has the value `git`, your local version of git on CI server will be used to get the branch name and commit hash. You also need to set `KNAPSACK_PRO_PROJECT_DIR` with the project directory path.

`KNAPSACK_PRO_PROJECT_DIR` - Path to the project on the CI node, for instance `/home/ubuntu/my-app-repository`. It should be the top-level directory of your repository.

#### When you don't use git

If your CI provider does not expose commit hash and branch name through environment variables, then `knapsack_pro` gem does not know these values.
You can manually set the values of the current commit hash and branch name in the environment variables:

* `KNAPSACK_PRO_COMMIT_HASH` - commit hash.
* `KNAPSACK_PRO_BRANCH` - branch name.

## Queue Mode

knapsack_pro has a built-in queue mode designed to determine the optimal test suite split even when there is an unpredictably longer time execution of test files on one node (e.g. by
CI node overload and decrease of performance that may affect how long the tests take on that node, or 
things like external requests done in individual tests).

### How does queue mode work?

On the Knapsack Pro API side, there is test file queue generated for your CI build. Each CI node periodically requests the Knapsack Pro API for test files
that should be executed next. Thanks to that each CI node will finish tests at the same time.

See how it works and what problems can be solved with Queue Mode https://youtu.be/hUEB1XDKEFY

### How to use queue mode?

Please don't use the same API token to run tests in Regular Mode and Queue Mode at the same time for your daily work.

Only when you setup your project for the first time use the same API token and please record whole test suite with Regular Mode then change knapsack pro command to Queue Mode and keep using the same API token.
Thanks to that your first CI build run in Queue Mode will use timing data recorded with Regular Mode to run tests in Queue Mode faster for the very first run.

Use this command to run Queue Mode:

```bash
# RSpec >= 3.x
bundle exec rake knapsack_pro:queue:rspec

# Minitest
bundle exec rake knapsack_pro:queue:minitest

# Cucumber
# If you use spring gem and spring-commands-cucumber gem to start Cucumber tests faster please set
# export KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX=bundle exec spring
# or you can use spring binstub
# export KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX=bin/spring
# Thanks to that Cucumber will start tests faster for each batch of tests fetched from Knapsack Pro Queue API
bundle exec rake knapsack_pro:queue:cucumber
```

If the above command fails for RSpec then you may need to explicitly pass an argument to require the `rails_helper` file or `spec_helper` in case you are not doing this in some of your test files:

```bash
bundle exec rake "knapsack_pro:queue:rspec[--require rails_helper]"
```

Note: when you run Queue Mode command for the first time without recording tests first in Regular Mode then CI build might be slower (especially for Cucumber).
The second CI build should have optimal test suite split with faster tests distribution across CI nodes in Queue Mode.

__Please ensure you have explicitly set `RAILS_ENV=test` on your CI nodes.__

If you use the capybara-screenshot gem then please [follow this step](#how-to-fix-capybara-screenshot-fail-with-systemstackerror-stack-level-too-deep-when-using-queue-mode-for-rspec).

If you use the rspec_junit_formatter gem then please [follow this step](#how-to-use-junit-formatter-with-knapsack_pro-queue-mode).

If your test suite is very long and the RSpec output is too long for your CI node then you can set log level `KNAPSACK_PRO_LOG_LEVEL=info` to don't show debug messages in RSpec output. [Read more about log level](#how-can-i-change-log-level).

### Additional info about queue mode

* You should use a separate API token for queue mode than for regular mode to avoid problems with test suite split (especially in case you would like to go back to regular mode).
There might be some cached test suite splits for git commits you have run in past for API token you used in queue mode because of the [flag `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true` for regular mode which is default](#knapsack_pro_fixed_test_suite_splite-test-suite-split-based-on-seed).

* If you are not using one of the [supported CI providers](#supported-ci-providers) then please note that the knapsack_pro gem doesn't have a CI build ID in order to generate a queue for each particular CI build. This may result in two different CI builds taking tests from the same queue when CI builds are running at the same time against the same git commit.

  To avoid this you should specify a unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` environment variable for each CI build. This mean that each CI node that is part of particular CI build should have the same value for `KNAPSACK_PRO_CI_NODE_BUILD_ID`.

* Note that in the Queue Mode by default you cannot retry the failed CI node with exactly the same subset of tests that were run on the CI node in the first place. It's possible in regular mode ([read more](#knapsack_pro_fixed_test_suite_splite-test-suite-split-based-on-seed)). If you want to have similar behavior in Queue Mode you need to explicitly [enable it](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

  By default the Queue Mode works this way:

  * If you retry the failed build and your all CI nodes start this new build then there will be a new dynamic test suite split across CI nodes. The reason is that the most of the CI providers schedule a new CI build with a different ID when you retry CI build. They retry all CI nodes again. In that case you don't have to worry with below edge cases because the CI build ID will be different so a new queue will be initialized on Knapsack Pro API side and all retried CI node will connect to that queue.

  Edge cases:

  * Let's say one of the CI nodes failed and you retry just this single CI node while other CI nodes are still running. Let's assume this retried CI node is part of the same CI build ID when you use supported CI provider or `KNAPSACK_PRO_CI_NODE_BUILD_ID` is defined and stays the same. The retried CI node will be connected to the queue consumed by still running CI nodes. You probably would expect the retried CI node to run the tests that were executed there on the first place. To achieve that you need to [enable it](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

  * Let's say one of the CI nodes failed and you retry just this single CI node while other CI nodes already finished work. Let's assume this retried CI node is part of the same CI build ID when you use supported CI provider or `KNAPSACK_PRO_CI_NODE_BUILD_ID` is defined and stays the same. The fact is all CI nodes finished work so the queue was consumed.
    * If you retry CI node in first hour since the CI build started for the first time then the retried CI node won't execute tests because the queue was consumed. There is important reason why it works like that. For instance some CI providers like Buildkite allows to start CI node later than the others so sometimes the particular CI node may start work while all other CI nodes finished work. In that case we don't want to run tests on the CI node because queue was already consumed. We don't know whether the CI node is part of the build or it is retried CI node hence the 1 hour lock on initializing a new queue.
    * If you retry CI node after 1 hour since the CI build started for the first time then the retried CI node will initialize a new queue and it will run whole test suite from the queue because there will be no other CI nodes running connected to the queue. The order of tests on retried CI node will be different than on the first run. You probably would expect the retried CI node to run the tests that were executed there on the first place. To achieve that you need to [enable it](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

  * When you use unsupported CI provider by knapsack_pro gem or you forget to set unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` per CI build then:
    * when you retry single CI node then it will initialize a new queue and it will run whole test suite from the queue because there will be no other CI nodes running connected to the queue. The order of tests on retried CI node will be different than on the first run.
    * when you retry all CI nodes then a new queue will be initialized and all CI nodes will connect to it.

### Extra configuration for Queue Mode

#### KNAPSACK_PRO_FIXED_QUEUE_SPLIT (remember queue split on retry CI node)

* `KNAPSACK_PRO_FIXED_QUEUE_SPLIT=false` (default)

  By default, the fixed queue split is off. It means when you will run tests for the same commit hash and a total number of nodes and for the same branch, and the CI build ID is different with second tests run then the queue will be generated dynamically and CI nodes will fetch from Knapsack Pro API the test files in a dynamic way. This is default because it gives the optimal test suite split for the whole test build across all CI nodes.

* `KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`

  You can enable fixed queue split in order to remember the test suite split across CI nodes when you used Queue Mode.

  It means when you run test suite or just retry single CI node again for the same commit hash and a total number of nodes and for the same branch
  then you will get exactly the same test suite split as it was when you run the build for the first time.

  Thanks to that when tests on one of your node failed you can retry the node with exactly the same subset of tests that were run on the node in the first place.

  __IMPORTANT__: [Required CI configuration if you use retry single failed CI node feature on your CI server when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true (in Queue Mode) or KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true (in Regular Mode)](#required-ci-configuration-if-you-use-retry-single-failed-ci-node-feature-on-your-ci-server-when-knapsack_pro_fixed_queue_splittrue-in-queue-mode-or-knapsack_pro_fixed_test_suite_splittrue-in-regular-mode)

  Other useful info:

  * Note when fixed queue split is enabled then you can run tests in a dynamic way only once for particular commit hash and a total number of nodes and for the same branch.

  * When Knapsack Pro API server has already information about previous queue split then the information will be used. You will see at the beginning of the knapsack command the log with info that queue name is nil because it was not generated this time. You will get the list of all test files that were executed on the particular CI node in the past.

    ```
    [knapsack_pro] {"queue_name"=>nil, "test_files"=>[{"path"=>"spec/foo_spec.rb", "time_execution"=>1.23}]}
    ```

  * Knapsack Pro is fault-tolerant and can withstand possible CI instance preemptions (shut down) when you use highly affordable CI nodes like [Google Cloud Preemptible VMs](https://cloud.google.com/preemptible-vms/) or [Amazon EC2 Spot Instances](https://aws.amazon.com/ec2/spot/). When you retry failed CI node or when your CI provider will do auto retry then the knapsack_pro will run tests previosly served to CI node that failed. After that it will try to consume the test files from the Queue if there are remaining test files that were not yet executed. You will see in the logs info that you retry the tests if the `queue_name` has prefix `retry-dead-ci-node`:

    ```
    [knapsack_pro] {"queue_name"=>"retry-dead-ci-node:queue-id", "test_files"=>[{"path"=>"spec/foo_spec.rb", "time_execution"=>1.23}]}
    ```

  * To [reproduce tests executed on CI node](#for-knapsack_pro-queue-mode) in development environment please see FAQ.

#### KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS (hide duplicated summary of pending and failed tests)

* `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=true` (default)

  By default, the knapsack_pro will monkey patch [RSpec Formatters](https://www.relishapp.com/rspec/rspec-core/v/2-6/docs/command-line/format-option) in order to
  hide the summary of pending and failed tests after each intermediate run of tests fetched from the work queue on Knapsack Pro API.
  knapsack_pro shows summary of all pending and failed tests at the very end when work queue ended. If you use your custom formatter and you have problem with it then you can disable `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false` monkey patching.

* `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false`

  It causes to show summary of pending and failed tests after each intermediate tests run from the work queue. The summary will grown cumulatively after each intermediate tests run so it means you will see multiple times summary of the same pending/failed tests. It doesn't mean the test files are executed twice. Test files are executed only once. Only summary report grows cumulatively.

### Supported test runners in queue mode

At this moment the queue mode works for:

* RSpec
* Minitest
* Cucumber

## Split test files by test cases

__How it works__: You can split slow test file by test cases. Thanks to that the slow test file can be split across parallel CI nodes because test cases from the test file will run on different CI nodes.

This is helpful when you have one or a few very slow test files that are a bottleneck for CI build speed and you don't want to manually create a few smaller test files from the slow test files. Instead, you can tell `knapsack_pro` gem to split your slow test files by test cases across parallel CI nodes.

Knapsack Pro API provides recorded timing of test files from your previously recorded CI builds and `knapsack_pro` gem will use this suggestion to determine slow test files. `knapsack_pro` gem splits only slow test files by test cases. Test files that are fast won't be split by test cases because it is not needed.

> __Note:__ This feature works for below test runners in Knapsack Pro Regular Mode and Queue Mode.

### RSpec split test files by test examples (by individual `it`s)

> ❗ __RSpec requirement:__ You need `RSpec >= 3.3.0` in order to use this feature.

In order to split RSpec slow test files by test examples across parallel CI nodes you need to set environment variable:

```
KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=true
```

Thanks to that your CI build speed can be faster. We recommend using this feature with [Queue Mode](https://youtu.be/hUEB1XDKEFY) to ensure parallel CI nodes finish work at a similar time which gives you the shortest CI build time.

#### Why I see error: Don't know how to build task 'knapsack_pro:rspec_test_example_detector'?

If you will see error like:

```
Don't know how to build task 'knapsack_pro:rspec_test_example_detector' (See the list of available tasks with `rake --tasks`)
```

It probably means bundler can't find the rake task. You can try to remove the default prefix `bundle exec` used by knapsack_pro gem by setting `KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX=""`.

### How to manually define a list of slow test files to be split by test cases

If you don't want to rely on a list of test files from Knapsack Pro API to determine slow test files that should be split by test cases then you can define your own list of slow test files.

```
# enable split by test cases for RSpec
KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=true

# example slow test files pattern for RSpec
KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN="{spec/models/user_spec.rb,spec/controllers/**/*_spec.rb}"
```

`KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN` must be subset of `KNAPSACK_PRO_TEST_FILE_PATTERN` (example default pattern for RSpec is `KNAPSACK_PRO_TEST_FILE_PATTERN="spec/**{,/*/**}/*_spec.rb"`).

> __Warning:__ `KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN` pattern is mostly useful for debugging purposes by developers of `knapsack_pro` gem. If you want to use it then __it is recommended to provide a shortlist of slow test files__ with the pattern.
>
> If you use a too broad list of slow test files then you may end up slowing your test suite, especially for RSpec it may result in a slow generating list of test examples in your project. The long list of test file example paths won't be accepted by Knapsack Pro API due to API timeout. CI providers like CircleCI may exceed server memory when running too many RSpec test examples.

## Extra configuration for CI server

### Info about ENV variables

By default knapsack_pro gem [supports a few CI providers](#supported-ci-providers) so you don't need to set some environment variables.
In case when you use other CI provider for instance [Jenkins](https://jenkins-ci.org) etc then you need to provide configuration via below environment variables.

`KNAPSACK_PRO_CI_NODE_TOTAL` - total number CI nodes you have.

`KNAPSACK_PRO_CI_NODE_INDEX` - index of current CI node starts from 0. Second CI node should have `KNAPSACK_PRO_CI_NODE_INDEX=1`.

#### KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT (test suite split based on seed)

Note this is for knapsack_pro regular mode only.

* `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true` (default)

    It means when you run test suite again for the same commit hash and total number of nodes and for the same branch
    then you will get exactly the same test suite split.

    Thanks to that when tests on one of your node failed you can retry the node with exactly the same subset of tests that were run on the node in the first place.

    __IMPORTANT__: [Required CI configuration if you use retry single failed CI node feature on your CI server when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true (in Queue Mode) or KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true (in Regular Mode)](#required-ci-configuration-if-you-use-retry-single-failed-ci-node-feature-on-your-ci-server-when-knapsack_pro_fixed_queue_splittrue-in-queue-mode-or-knapsack_pro_fixed_test_suite_splittrue-in-regular-mode)

    Other useful info:

    * There is one edge case. When you run tests for the first time and there is no data collected about time execution of your tests then
      we need to collect data to prepare the first test suite split. The second run of your tests will have fixed test suite split.

      To compare if all your CI nodes are running based on the same test suite split seed you can check the value for seed in knapsack logging message
      before your test starts. The message looks like:

      ```
      [knapsack_pro] Test suite split seed: 8a606431-02a1-4766-9878-0ea42a07ad21
      ```

* `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=false`

    When you disable fixed test suite split then your will get test suite split based on most up to date data about your test suite time execution.
    For instance, when you run tests for the second time for the same commit hash then your will get more optimal test suite split than it was on the first run.

    Don't disable fixed test suite split when:

    * you expect to run the same subset of test suite multiple times for the same node (for instance your would like to retry only single CI node that failed)

        Example of issue:
        * https://github.com/KnapsackPro/knapsack_pro-ruby/issues/15
        * https://github.com/KnapsackPro/knapsack_pro-ruby/issues/12

    * you start your tests not at the same time across your CI nodes. For instance, one of the CI node finished faster than the other CI node started. This would change the seed for the second CI node that started later.

#### Environment variables for debugging gem

This is only for maintainer of knapsack_pro gem. Not for the end users.

* `KNAPSACK_PRO_ENDPOINT` - Default value is `https://api.knapsackpro.com` which is endpoint for [Knapsack Pro API](http://docs.knapsackpro.com).

* `KNAPSACK_PRO_MODE` - Default value is `production` and then endpoint is `https://api.knapsackpro.com`.
  * When mode is `development` then endpoint is `http://api.knapsackpro.test:3000`.
  * When mode is `test` then endpoint is `https://api-staging.knapsackpro.com`.

### Required CI configuration if you use retry single failed CI node feature on your CI server when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true (in Queue Mode) or KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true (in Regular Mode)

Read below required configuration step if you use Queue Mode and you set [`KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node) or you use Regular Mode which has by default [`KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true`](#knapsack_pro_fixed_test_suite_splite-test-suite-split-based-on-seed).

* __IMPORTANT:__ If you use __the feature to retry only a single failed CI node__ on your CI server (for instance you use Buildkite and you use [auto-retry](https://buildkite.com/docs/pipelines/command-step#retry-attributes) for the failed job) then you need to be aware of [a race condition that could happen](https://github.com/KnapsackPro/knapsack_pro-ruby/pull/100). knapsack_pro should not allow running tests in Fallback Mode in the case when the failed CI node was retried to prevent running the wrong set of tests.

  knapsack_pro has built-in support for retries of failed parallel CI nodes for listed CI servers:

  * Buildkite (knapsack_pro reads `BUILDKITE_RETRY_COUNT`)

  knapsack_pro reads ENV vars for above CI servers and it disables Fallback Mode when failed parallel CI node can't connect with Knapsack Pro API. This way we prevent running the wrong set of tests by Fallback Mode on retried CI node.

  If you use other CI server you need to manually configure your CI server to set `KNAPSACK_PRO_CI_NODE_RETRY_COUNT=1` only during retry CI node attempt. If `KNAPSACK_PRO_CI_NODE_RETRY_COUNT > 0` then knapsack_pro won't allow starting running tests in Fallback Mode and instead will raise error so a user can manually retry CI node later when a connection to Knapsack Pro API can be established.

  If you cannot set `KNAPSACK_PRO_CI_NODE_RETRY_COUNT` only for retried CI node or it is not possible for your CI server then you can disable Fallback Mode completely `KNAPSACK_PRO_FALLBACK_MODE_ENABLED=false`. When Fallback Mode is disabled then knapsack_pro gem will try to connect to Knapsack Pro API 6 times instead of only 3 times to ensure there is a low chance of failing your CI node due to lost connection with the API.

### Passing arguments to rake task

#### Passing arguments to rspec

Knapsack Pro allows you to pass arguments through to rspec. For example if you want to run only specs that have the tag `focus`. If you do this with rspec directly it would look like:

```bash
bundle exec rake rspec --tag focus
```

To do this with Knapsack Pro you simply add your rspec arguments as parameters to the knapsack_pro rake task.

```bash
bundle exec rake "knapsack_pro:rspec[--tag focus]"
```

#### Passing arguments to cucumber

Add arguments to knapsack_pro cucumber task like this:

```bash
bundle exec rake "knapsack_pro:cucumber[--name feature]"
```

#### Passing arguments to minitest

Add arguments to knapsack_pro minitest task like this:

```bash
bundle exec rake "knapsack_pro:minitest[--arg_name value]"
```

For instance to run verbose tests:

```bash
bundle exec rake "knapsack_pro:minitest[--verbose]"
```

#### Passing arguments to test-unit

Add arguments to knapsack_pro test-unit task like this:

```bash
bundle exec rake "knapsack_pro:test_unit[--arg_name value]"
```

For instance to run verbose tests:

```bash
bundle exec rake "knapsack_pro:test_unit[--verbose]"
```

#### Passing arguments to spinach

Add arguments to knapsack_pro spinach task like this:

```bash
bundle exec rake "knapsack_pro:spinach[--arg_name value]"
```

### Knapsack Pro binary

You can install knapsack_pro globally and use binary. For instance:

```bash
knapsack_pro rspec "--tag custom_tag_name --profile"
knapsack_pro queue:rspec "--tag custom_tag_name --profile"
knapsack_pro cucumber "--name feature"
knapsack_pro queue:cucumber "--name feature"
knapsack_pro minitest "--verbose --pride"
knapsack_pro queue:minitest "--verbose"
knapsack_pro test_unit "--verbose"
knapsack_pro spinach "--arg_name value"
```

This is optional way of using knapsack_pro when you don't want to add it to `Gemfile`.

### Test file names encryption

knapsack_pro gem collects information about you test file names and time execution. Those data are stored on KnapsackPro.com server.
If your test file names or branch names are sensitive data then you can encrypt the names before sending them to KnapsackPro.com API.

By default, encryption is disabled because knapsack_pro can use your test files names to prepare better test suite split when the time execution data are not yet collected on KnapsackPro.com server.
When you will enable test file names encryption then your first test suite split may be less optimal than it could be.

Each test file name is generated with `Digest::SHA2.hexdigest` method and 64 chars salt.

Before you enable test file encryption please ensure you are using fresh API key. You should not use the same API key for encrypted and non encrypted test suite.
You can generate API key for your test suite in [your dashboard](https://knapsackpro.com).

Next step is to generate salt which will be used to encrypt test files or branch names.

```bash
bundle exec rake knapsack_pro:salt
```

Add to your CI server generated environment variable `KNAPSACK_PRO_SALT`.

#### How to enable test file names encryption?

You need to add environment variable `KNAPSACK_PRO_TEST_FILES_ENCRYPTED=true` to your CI server.

#### How to debug test file names?

If you need to check what is the encryption hash for particular test file you can check that with the rake task:

```bash
KNAPSACK_PRO_SALT=xxx bundle exec rake knapsack_pro:encrypted_test_file_names[rspec]
```

You can pass the name of test runner like `rspec`, `minitest`, `test_unit`, `cucumber`, `spinach` as argument to rake task.

##### Preview encrypted RSpec test example paths?

If you split RSpec tests by test examples (by individual `it`) you can preview encrypted test example paths this way:

```bash
KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=true \
KNAPSACK_PRO_SALT=xxx \
bundle exec rake knapsack_pro:encrypted_test_file_names[rspec]
```

#### How to enable branch names encryption?

You need to add environment variable `KNAPSACK_PRO_BRANCH_ENCRYPTED=true` to your CI server.

Note: there are a few branch names that won't be encrypted because we use them as fallback branches on Knapsack Pro API side to determine time execution for test files during split for newly created branches.

* develop
* development
* dev
* master
* staging
* [see full list of encryption excluded branch names](https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/lib/knapsack_pro/crypto/branch_encryptor.rb#L4)

#### How to debug branch names?

If you need to check what is the encryption hash for particular branch then use the rake task:

```bash
# show all local branches and respective hashes
$ KNAPSACK_PRO_SALT=xxx bundle exec rake knapsack_pro:encrypted_branch_names

# show hash for branch provided as argument to rake task
$ KNAPSACK_PRO_SALT=xxx bundle exec rake knapsack_pro:encrypted_branch_names[not-encrypted-branch-name]
```

### Supported CI providers

#### Info for CircleCI users

If you are using circleci.com you can omit `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX`. Knapsack Pro will use `CIRCLE_NODE_TOTAL` and `CIRCLE_NODE_INDEX` provided by CircleCI.

Here is an example for test configuration in your `circleci.yml` file.

```yaml
# CircleCI 1.0

machine:
  environment:
    # Tokens should be set in CircleCI settings to avoid expose tokens in build logs
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC: rspec-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER: cucumber-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST: minitest-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT: test-unit-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH: spinach-token
test:
  override:
    # Step for RSpec
    - bundle exec rake knapsack_pro:rspec:
        parallel: true # Caution: there are 8 spaces indentation!

    # Step for Cucumber
    - bundle exec rake knapsack_pro:cucumber:
        parallel: true # Caution: there are 8 spaces indentation!

    # Step for Minitest
    - bundle exec rake knapsack_pro:minitest:
        parallel: true # Caution: there are 8 spaces indentation!

    # Step for test-unit
    - bundle exec rake knapsack_pro:test_unit:
        parallel: true # Caution: there are 8 spaces indentation!

    # Step for Spinach
    - bundle exec rake knapsack_pro:spinach:
        parallel: true # Caution: there are 8 spaces indentation!
```

Here is another example for CircleCI 2.0 platform.

```yaml
# CircleCI 2.0

# some tests that are not balanced and executed only on first CI node
- run: case $CIRCLE_NODE_INDEX in 0) npm test ;; esac

# auto-balancing CI build time execution to be flat and optimal (as fast as possible).
# Queue Mode does dynamic tests allocation so the previous not balanced run command won't
# create a bottleneck on the CI node
- run:
  name: RSpec via knapsack_pro Queue Mode
  command: |
    # export word is important here!
    export RAILS_ENV=test
    bundle exec rake "knapsack_pro:queue:rspec[--format documentation]"

- run:
  name: Minitest via knapsack_pro Queue Mode
  command: |
    # export word is important here!
    export RAILS_ENV=test
    bundle exec rake "knapsack_pro:queue:minitest[--verbose]"

- run:
  name: Cucumber via knapsack_pro Queue Mode
  command: |
    # export word is important here!
    export RAILS_ENV=test
    bundle exec rake knapsack_pro:queue:cucumber
```

Please remember to add additional containers for your project in CircleCI settings.

##### CircleCI and knapsack_pro Queue Mode

If you use knapsack_pro Queue Mode with CircleCI you may want to [collect metadata](https://circleci.com/docs/1.0/test-metadata/#metadata-collection-in-custom-test-steps) like junit xml report about your RSpec test suite.

Here you can read how to configure [junit formatter](#how-to-use-junit-formatter-with-knapsack_pro-queue-mode). Step for CircleCI is to copy the xml report to `$CIRCLE_TEST_REPORTS` directory. Below is full config for your `spec_helper.rb`:

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain sign ~, for instance path ~/project/tmp/rspec.xml may not work. Please use full path instead.
TMP_RSPEC_XML_REPORT = 'tmp/rspec.xml'
# move results to FINAL_RSPEC_XML_REPORT so the results won't accumulate with duplicated xml tags in TMP_RSPEC_XML_REPORT
FINAL_RSPEC_XML_REPORT = 'tmp/rspec_final_results.xml'

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  if File.exist?(TMP_RSPEC_XML_REPORT)
    FileUtils.mv(TMP_RSPEC_XML_REPORT, FINAL_RSPEC_XML_REPORT)
  end
end

# Here is additional configuration to ensure the xml report will be visible by CircleCI
KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  # Metadata collection
  # https://circleci.com/docs/2.0/collect-test-data/#metadata-collection-in-custom-test-steps
  if File.exist?(FINAL_RSPEC_XML_REPORT) && ENV['CIRCLE_TEST_REPORTS']
    FileUtils.cp(FINAL_RSPEC_XML_REPORT, "#{ENV['CIRCLE_TEST_REPORTS']}/rspec.xml")
  end
end
```

Ensure you have in CircleCI config yml

```yaml
- run:
    name: RSpec via knapsack_pro Queue Mode
    command: |
      export CIRCLE_TEST_REPORTS=/tmp/test-results
      mkdir $CIRCLE_TEST_REPORTS
      bundle exec rake "knapsack_pro:queue:rspec[--format documentation --format RspecJunitFormatter --out tmp/rspec.xml]"

# collect reports
- store_test_results:
    path: /tmp/test-results
- store_artifacts:
    path: /tmp/test-results
    destination: test-results
```

#### Info for Travis users

You can parallelize your builds across virtual machines with [travis matrix feature](http://docs.travis-ci.com/user/speeding-up-the-build/#parallelizing-your-builds-across-virtual-machines). Edit `.travis.yml`

```yaml
script:
  # Step for RSpec in Regular Mode
  - "bundle exec rake knapsack_pro:rspec"

  # Step for RSpec in Queue Mode
  - "bundle exec rake knapsack_pro:queue:rspec"

  # Step for Cucumber in Regular Mode
  - "bundle exec rake knapsack_pro:cucumber"

  # Step for Cucumber in Queue Mode
  - "bundle exec rake knapsack_pro:queue:cucumber"

  # Step for Minitest in Regular Mode
  - "bundle exec rake knapsack_pro:minitest"

  # Step for Minitest in Queue Mode
  - "bundle exec rake knapsack_pro:queue:minitest"

  # Step for test-unit in Regular Mode
  - "bundle exec rake knapsack_pro:test_unit"

  # Step for Spinach in Regular Mode
  - "bundle exec rake knapsack_pro:spinach"

env:
  global:
    # tokens should be set in travis settings in web interface to avoid expose tokens in build logs
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT=test-unit-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token

    # if you use Knapsack Pro Queue Mode you must set below env variable
    # to be able to retry single failed parallel job from Travis UI
    - KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true

    - KNAPSACK_PRO_CI_NODE_TOTAL=2
  jobs:
    - KNAPSACK_PRO_CI_NODE_INDEX=0
    - KNAPSACK_PRO_CI_NODE_INDEX=1
```

Such configuration will generate matrix with 2 following ENV rows:

    KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT=test-unit-token KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token
    KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT=test-unit-token KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token

More info about global and matrix ENV configuration in [travis docs](https://docs.travis-ci.com/user/customizing-the-build/#build-matrix).

#### Info for semaphoreci.com users

##### Semaphore 2.0

knapsack_pro gem supports environment variables provided by Semaphore CI 2.0 to run your tests. You will have to define a few things in `.semaphore/semaphore.yml` config file.

* You need to set `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC`. If you don't want to commit secrets in yml file then you can [follow this guide](https://docs.semaphoreci.com/article/66-environment-variables-and-secrets).
* You should create as many parallel jobs as you need with `parallelism` property. If your test suite is long you should use more parallel jobs.

Below you can find full Semaphore CI 2.0 config for Rails project.

```yaml
# .semaphore/semaphore.yml
# Use the latest stable version of Semaphore 2.0 YML syntax:
version: v1.0

# Name your pipeline. In case you connect multiple pipelines with promotions,
# the name will help you differentiate between, for example, a CI build phase
# and delivery phases.
name: Demo Rails 5 app

# An agent defines the environment in which your code runs.
# It is a combination of one of available machine types and operating
# system images.
# See https://docs.semaphoreci.com/article/20-machine-types
# and https://docs.semaphoreci.com/article/32-ubuntu-1804-image
agent:
  machine:
    type: e1-standard-2
    os_image: ubuntu1804

# Blocks are the heart of a pipeline and are executed sequentially.
# Each block has a task that defines one or more jobs. Jobs define the
# commands to execute.
# See https://docs.semaphoreci.com/article/62-concepts
blocks:
  - name: Setup
    task:
      env_vars:
        - name: RAILS_ENV
          value: test
      jobs:
        - name: bundle
          commands:
          # Checkout code from Git repository. This step is mandatory if the
          # job is to work with your code.
          # Optionally you may use --use-cache flag to avoid roundtrip to
          # remote repository.
          # See https://docs.semaphoreci.com/article/54-toolbox-reference#libcheckout
          - checkout
          # Restore dependencies from cache.
          # Read about caching: https://docs.semaphoreci.com/article/54-toolbox-reference#cache
          - cache restore gems-$SEMAPHORE_GIT_BRANCH-$(checksum Gemfile.lock),gems-$SEMAPHORE_GIT_BRANCH-,gems-master-
          # Set Ruby version:
          - sem-version ruby 2.6.1
          - bundle install --jobs=4 --retry=3 --path vendor/bundle
          # Store the latest version of dependencies in cache,
          # to be used in next blocks and future workflows:
          - cache store gems-$SEMAPHORE_GIT_BRANCH-$(checksum Gemfile.lock) vendor/bundle

  - name: RSpec tests
    task:
      env_vars:
        - name: RAILS_ENV
          value: test
        - name: PGHOST
          value: 127.0.0.1
        - name: PGUSER
          value: postgres
        - name: KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC
          value: your_api_token_here
      # This block runs two jobs in parallel and they both share common
      # setup steps. We can group them in a prologue.
      # See https://docs.semaphoreci.com/article/50-pipeline-yaml#prologue
      prologue:
        commands:
          - checkout
          - cache restore gems-$SEMAPHORE_GIT_BRANCH-$(checksum Gemfile.lock),gems-$SEMAPHORE_GIT_BRANCH-,gems-master-
          # Start Postgres database service.
          # See https://docs.semaphoreci.com/article/54-toolbox-reference#sem-service
          - sem-service start postgres
          - sem-version ruby 2.6.1
          - bundle install --jobs=4 --retry=3 --path vendor/bundle
          - bundle exec rake db:setup

      jobs:
      - name: Run tests with Knapsack Pro
        parallelism: 2
        commands:
        # Step for RSpec in Queue Mode
        - bundle exec rake knapsack_pro:queue:rspec
        # Step for Cucumber in Queue Mode
        - bundle exec rake knapsack_pro:queue:cucumber

        # Step for RSpec in Regular Mode
        - bundle exec rake knapsack_pro:rspec
        # Step for Cucumber in Regular Mode
        - bundle exec rake knapsack_pro:cucumber
        # Step for Minitest in Regular Mode
        - bundle exec rake knapsack_pro:minitest
        # Step for test-unit in Regular Mode
        - bundle exec rake knapsack_pro:test_unit
        # Step for Spinach in Regular Mode
        - bundle exec rake knapsack_pro:spinach
```

##### Semaphore 1.0

Knapsack Pro supports semaphoreapp ENVs `SEMAPHORE_THREAD_COUNT` and `SEMAPHORE_CURRENT_THREAD`. The only thing you need to do is set up knapsack_pro rspec/cucumber/minitest/test_unit command for as many threads as you need. Here is an example:

```bash
# Thread 1
## Step for RSpec
bundle exec rake knapsack_pro:rspec
## Step for Cucumber
bundle exec rake knapsack_pro:cucumber
## Step for Minitest
bundle exec rake knapsack_pro:minitest
## Step for test-unit
bundle exec rake knapsack_pro:test_unit
## Step for Spinach
bundle exec rake knapsack_pro:spinach

# Thread 2
## Step for RSpec
bundle exec rake knapsack_pro:rspec
## Step for Cucumber
bundle exec rake knapsack_pro:cucumber
## Step for Minitest
bundle exec rake knapsack_pro:minitest
## Step for test-unit
bundle exec rake knapsack_pro:test_unit
## Step for Spinach
bundle exec rake knapsack_pro:spinach
```

Tests will be split across threads.

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for buildkite.com users

Knapsack Pro supports buildkite ENVs `BUILDKITE_PARALLEL_JOB_COUNT` and `BUILDKITE_PARALLEL_JOB`. The only thing you need to do is to configure the parallelism parameter in your build step and run the appropiate command in your build

```bash
# Step for RSpec
bundle exec rake knapsack_pro:rspec

# Step for Cucumber
bundle exec rake knapsack_pro:cucumber

# Step for Minitest
bundle exec rake knapsack_pro:minitest

# Step for test-unit
bundle exec rake knapsack_pro:test_unit

# Step for Spinach
bundle exec rake knapsack_pro:spinach
```

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

Here you can find article [how to set up a new pipeline for your project in Buildkite and configure Knapsack Pro](http://docs.knapsackpro.com/2017/auto-balancing-7-hours-tests-between-100-parallel-jobs-on-ci-buildkite-example) and 2 example repositories for Ruby/Rails projects:

* [Buildkite Rails Parallel Example with Knapsack Pro](https://github.com/KnapsackPro/buildkite-rails-parallel-example-with-knapsack_pro)
* [Buildkite Rails Docker Parallel Example with Knapsack Pro](https://github.com/KnapsackPro/buildkite-rails-docker-parallel-example-with-knapsack_pro)

If you want to use Buildkite retry single agent feature to retry just failed tests on particular agent (CI node) then you should set [`KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

When using the `docker-compose` plugin on Buildkite, you have to tell it which environment variables to pass to the docker container. Thanks to it knapsack_pro can detect info about CI build like commit, branch name, amount of parallel nodes.

```yaml
steps:
  - label: "Test"
    parallelism: 2
    plugins:
      - docker-compose#3.0.3:
        run: app
        # use here proper knapsack_pro command for your test runner
        command: bundle exec rake knapsack_pro:queue:rspec
        config: docker-compose.test.yml
        env:
          - BUILDKITE_PARALLEL_JOB_COUNT
          - BUILDKITE_PARALLEL_JOB
          - BUILDKITE_BUILD_NUMBER
          - BUILDKITE_COMMIT
          - BUILDKITE_BRANCH
          - BUILDKITE_BUILD_CHECKOUT_PATH
```

#### Info for GitLab CI users

Remember to add API tokens like `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER` and `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` to [Secret Variables](https://gitlab.com/help/ci/variables/README.md#secret-variables) in `GitLab CI Settings -> CI/CD Pipelines -> Secret Variables`.

##### GitLab CI `>= 11.5`

```yaml
test:
  parallel: 2

  # Knapsack Pro Regular Mode (deterministic test suite split)
  script: bundle exec rake knapsack_pro:rspec

  # Other commands you could use:

  # Knapsack Pro Regular Mode (deterministic test suite split)
  # bundle exec rake knapsack_pro:cucumber
  # bundle exec rake knapsack_pro:minitest
  # bundle exec rake knapsack_pro:test_unit
  # bundle exec rake knapsack_pro:spinach

  # Knapsack Pro Queue Mode (dynamic test suite split)
  # bundle exec rake knapsack_pro:queue:rspec
  # bundle exec rake knapsack_pro:queue:minitest
  # bundle exec rake knapsack_pro:queue:cucumber
```

Here you can find info [how to configure the GitLab parallel CI nodes](https://docs.gitlab.com/ee/ci/yaml/#parallel).

##### GitLab CI `< 11.5` (old GitLab CI)

GitLab CI does not provide parallel jobs environment variables so you will have to define `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX` for each parallel job running as part of the same `test` stage. Below is relevant part of `.gitlab-ci.yml` configuration for 2 parallel jobs.

```yaml
# .gitlab-ci.yml
stages:
  - test

variables:
  KNAPSACK_PRO_CI_NODE_TOTAL: 2

# first CI node running in parallel
test_ci_node_0:
  stage: test
  script:
    - export KNAPSACK_PRO_CI_NODE_INDEX=0
    # Cucumber tests in Knapsack Pro Regular Mode (deterministic test suite split)
    - bundle exec rake knapsack_pro:cucumber
    # or use Cucumber tests in Knapsack Pro Queue Mode (dynamic test suite split)
    - bundle exec rake knapsack_pro:queue:cucumber
    # RSpec tests in Knapsack Pro Queue Mode (dynamic test suite split)
    # It will autobalance build because it is executed after Cucumber tests.
    - bundle exec rake knapsack_pro:queue:rspec

# second CI node running in parallel
test_ci_node_1:
  stage: test
  script:
    - export KNAPSACK_PRO_CI_NODE_INDEX=1
    - bundle exec rake knapsack_pro:cucumber
    - bundle exec rake knapsack_pro:queue:cucumber
    - bundle exec rake knapsack_pro:queue:rspec
```

#### Info for codeship.com users

Codeship does not provide parallel jobs environment variables so you will have to define `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX` for each [parallel test pipeline](https://documentation.codeship.com/basic/builds-and-configuration/parallel-tests/#using-parallel-test-pipelines). Below is an example for 2 parallel test pipelines.

Configure test pipelines (1/2 used)

```bash
# first CI node running in parallel

# Cucumber tests in Knapsack Pro Regular Mode (deterministic test suite split)
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

# or use Cucumber tests in Knapsack Pro Queue Mode (dynamic test suite split)
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:queue:cucumber

# RSpec tests in Knapsack Pro Queue Mode (dynamic test suite split)
# It will autobalance build because it is executed after Cucumber tests.
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:queue:rspec
```

Configure test pipelines (2/2 used)

```bash
# second CI node running in parallel

# Cucumber tests in Knapsack Pro Regular Mode (deterministic test suite split)
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:cucumber

# or use Cucumber tests in Knapsack Pro Queue Mode (dynamic test suite split)
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:queue:cucumber

# RSpec tests in Knapsack Pro Queue Mode (dynamic test suite split)
# It will autobalance build because it is executed after Cucumber tests.
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:queue:rspec
```

Remember to add API tokens like `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER` and `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` to `Environment` page of your project settings in Codeship.

CodeShip uses the same build number if you restart a build. Because of that you need to set [`KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node) in order to be able to restart CI build in Queue Mode.

#### Info for Heroku CI users

You can parallelize your tests on Heroku CI by configuring `app.json`.

You can set how many parallel dynos with tests you want to run with `quantity` value.
Use `test` key to run knapsack_pro gem.

You need to specify also the environment variable with API token for Knapsack Pro.
For any sensitive environment variables (like Knapsack Pro API token) that you do not want in your `app.json` manifest, you can add them to your pipeline’s Heroku CI settings.

Note the [Heroku CI Parallel Test Runs](https://devcenter.heroku.com/articles/heroku-ci-parallel-test-runs) are in Beta and you may need to ask Heroku support to enabled it for your project.

```json
# app.json
{
  "environments": {
    "test": {
      "formation": {
        "test": {
          "quantity": 2
        }
      },
      "addons": [
        "heroku-postgresql"
      ],
      "scripts": {
        "test": "bundle exec rake knapsack_pro:rspec"
      },
      "env": {
        "KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC": "rspec-token"
      }
    }
  }
}
```

You can learn more about [Heroku CI](https://devcenter.heroku.com/articles/heroku-ci).

#### Info for Solano CI users

[Solano CI](https://www.solanolabs.com) does not provide parallel jobs environment variables so you will have to define `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX` for each parallel job running as part of the same CI build.

```bash
# Step for RSpec for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec
# Step for RSpec for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:rspec

# Step for Cucumber for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber
# Step for Cucumber for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:cucumber

# Step for Minitest for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest
# Step for Minitest for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:minitest

# Step for test-unit for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:test_unit
# Step for test-unit for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:test_unit

# Step for Spinach for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach
# Step for Spinach for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:spinach
```

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for AppVeyor users

[AppVeyor](https://www.appveyor.com) does not provide parallel jobs environment variables so you will have to define `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX` for each parallel job running as part of the same CI build.

```bash
# Step for RSpec for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec
# Step for RSpec for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:rspec

# Step for Cucumber for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber
# Step for Cucumber for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:cucumber

# Step for Minitest for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest
# Step for Minitest for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:minitest

# Step for test-unit for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:test_unit
# Step for test-unit for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:test_unit

# Step for Spinach for first CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach
# Step for Spinach for second CI node
KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:spinach
```

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for snap-ci.com users

Knapsack Pro supports snap-ci.com ENVs `SNAP_WORKER_TOTAL` and `SNAP_WORKER_INDEX`. The only thing you need to do is to configure number of workers for your project in configuration settings in order to enable parallelism. Next thing is to set below commands to be executed in your stage:

```bash
# Step for RSpec
bundle exec rake knapsack_pro:rspec

# Step for Cucumber
bundle exec rake knapsack_pro:cucumber

# Step for Minitest
bundle exec rake knapsack_pro:minitest

# Step for test-unit
bundle exec rake knapsack_pro:test_unit

# Step for Spinach
bundle exec rake knapsack_pro:spinach
```

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for cirrus-ci.org users

Knapsack Pro supports cirrus-ci.org ENVs `CI_NODE_TOTAL` and `CI_NODE_INDEX`. The only thing you need to do is to configure number of parallel CI nodes for your project. Next thing is to set one of below commands to be executed on each parallel CI node:

```bash
# Step for RSpec
bundle exec rake knapsack_pro:rspec

# Step for Cucumber
bundle exec rake knapsack_pro:cucumber

# Step for Minitest
bundle exec rake knapsack_pro:minitest

# Step for test-unit
bundle exec rake knapsack_pro:test_unit

# Step for Spinach
bundle exec rake knapsack_pro:spinach
```

Please remember to set up API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

Here is example for [`.cirrus.yml` configuration file](https://cirrus-ci.org/examples/#ruby).

#### Info for Jenkins users

In order to run parallel jobs with Jenkins you should use Jenkins Pipeline.
You can learn basics about it in the article [Parallelism and Distributed Builds with Jenkins](https://www.cloudbees.com/blog/parallelism-and-distributed-builds-jenkins).

Here is example `Jenkinsfile` working with Jenkins Pipeline.

```groovy
timeout(time: 60, unit: 'MINUTES') {
  node() {
    stage('Checkout') {
      checkout([/* checkout code from git */])

      // determine git commit hash because we need to pass it to knapsack_pro
      COMMIT_HASH = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()

      stash 'source'
    }
  }

  def num_nodes = 4; // define your total number of CI nodes (how many parallel jobs will be executed)
  def nodes = [:]

  for (int i = 0; i < num_nodes; i++) {
    def index = i;
    nodes["ci_node_${i}"] = {
      node() {
        stage('Setup') {
          unstash 'source'
          // other setup steps
        }

        def knapsack_options = """\
            KNAPSACK_PRO_CI_NODE_TOTAL=${num_nodes}\
            KNAPSACK_PRO_CI_NODE_INDEX=${index}\
            KNAPSACK_PRO_COMMIT_HASH=${COMMIT_HASH}\
            KNAPSACK_PRO_BRANCH=${env.BRANCH_NAME}\
        """

        // example how to run cucumber tests in Knapsack Pro Regular Mode
        stage('Run cucumber') {
          sh """${knapsack_options} bundle exec rake knapsack_pro:cucumber"""
        }

        // example how to run rspec tests in Knapsack Pro Queue Mode
        // Queue Mode should be as a last stage so it can autobalance build if tests in regular mode were not perfectly distributed
        stage('Run rspec') {
          sh """KNAPSACK_PRO_CI_NODE_BUILD_ID=${env.BUILD_TAG} ${knapsack_options} bundle exec rake knapsack_pro:queue:rspec"""
        }
      }
    }
  }

  parallel nodes // run CI nodes in parallel
}
```

Remember to set environment variables in Jenkins configuration with your API tokens like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` and `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER`.
Here is [list of environment variables per test runner](#set-api-key-token).

Above example shows how to run cucumber tests in regular mode and later the rspec tests in queue mode to autobalance build.
If you are going to relay on rspec to autobalance build when cucumber tests were not perfectly distributed you should be aware about [possible edge case if your rspec test suite is very short](#why-my-tests-are-executed-twice-in-queue-mode-why-ci-node-runs-whole-test-suite-again).

#### Info for GitHub Actions users

knapsack_pro gem supports environment variables provided by GitHub Actions to run your tests. You will have to define a few things in `.github/workflows/main.yaml` config file.

* You need to set API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` in GitHub settings -> Secrets for your repository. [Creating and using secrets in GitHub Actions](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables).
* You should create as many parallel jobs as you need with [`matrix` property](https://help.github.com/en/articles/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix). If your test suite is slow you should use more parallel jobs. See comment in below config.

Below you can find full GitHub Actions config for Ruby on Rails project.

```yaml
# .github/workflows/main.yaml
name: Main

on: [push]

jobs:
  vm-job:
    runs-on: ubuntu-latest

    # If you need DB like PostgreSQL then define service below.
    # Example for Redis can be found here:
    # https://github.com/actions/example-services/tree/master/.github/workflows
    services:
      postgres:
        image: postgres:10.8
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: ""
          POSTGRES_DB: postgres
        ports:
        # will assign a random free host port
        - 5432/tcp
        # needed because the postgres container does not provide a healthcheck
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5

    strategy:
      fail-fast: false
      matrix:
        # Set N number of parallel jobs you want to run tests on.
        # Use higher number if you have slow tests to split them on more parallel jobs.
        # Remember to update ci_node_index below to 0..N-1
        ci_node_total: [2]
        # set N-1 indexes for parallel jobs
        # When you run 2 parallel jobs then first job will have index 0, the second job will have index 1 etc
        ci_node_index: [0, 1]

    steps:
    - uses: actions/checkout@v1

    - name: Set up Ruby 2.6
      uses: actions/setup-ruby@v1
      with:
        ruby-version: 2.6.5

    - uses: actions/cache@v1
      with:
        path: vendor/bundle
        key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
        restore-keys: |
          ${{ runner.os }}-gems-

    # required to compile pg ruby gem
    - name: install PostgreSQL client
      run: sudo apt-get install libpq-dev

    - name: Build and create DB
      env:
        # use localhost for the host here because we have specified a container for the job.
        # If we were running the job on the VM this would be postgres
        PGHOST: localhost
        PGUSER: postgres
        PGPORT: ${{ job.services.postgres.ports[5432] }} # get randomly assigned published port
        RAILS_ENV: test
      run: |
        gem install bundler
        bundle config path vendor/bundle
        bundle install --jobs 4 --retry 3
        bin/rails db:setup

    - name: Run tests
      env:
        PGHOST: localhost
        PGUSER: postgres
        PGPORT: ${{ job.services.postgres.ports[5432] }} # get randomly assigned published port
        RAILS_ENV: test
        KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC: ${{ secrets.KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC }}
        KNAPSACK_PRO_CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
        KNAPSACK_PRO_CI_NODE_INDEX: ${{ matrix.ci_node_index }}
        # if you use Knapsack Pro Queue Mode you must set below env variable
        # to be able to retry CI build and run previously recorded tests
        KNAPSACK_PRO_FIXED_QUEUE_SPLIT: true
      run: |
        # run tests in Knapsack Pro Regular Mode
        bundle exec rake knapsack_pro:rspec
        bundle exec rake knapsack_pro:cucumber
        bundle exec rake knapsack_pro:minitest
        bundle exec rake knapsack_pro:test_unit
        bundle exec rake knapsack_pro:spinach

        # you can use Knapsack Pro in Queue Mode once recorded first CI build with Regular Mode
        bundle exec rake knapsack_pro:queue:rspec
        bundle exec rake knapsack_pro:queue:cucumber
        bundle exec rake knapsack_pro:queue:minitest
```

#### Info for Codefresh.io users

knapsack_pro gem supports environment variables provided by Codefresh.io to run your tests. You will have to define a few things in `.codefresh/codefresh.yml` config file.

* You need to set an API token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` in Codefresh dashboard, see left menu Pipelines -> settings (cog icon next to the pipeline) -> Variables tab (see a vertical menu on the right side). Add there new API token depending on the test runner you use:
  * `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC`
  * `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER`
  * `KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST`
  * `KNAPSACK_PRO_TEST_SUITE_TEST_UNIT`
  * `KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH`
* Set where Codefresh YAML file can be found. In Codefresh dashboard, see left menu Pipelines -> settings (cog icon next to pipeline) -> Workflow tab (horizontal menu on the top) -> Path to YAML (set there `./.codefresh/codefresh.yml`).
* Set how many parallel jobs (parallel CI nodes) you want to run with `KNAPSACK_PRO_CI_NODE_TOTAL` environment variable in `.codefresh/codefresh.yml` file.
* Ensure in the `matrix` section you listed all `KNAPSACK_PRO_CI_NODE_INDEX` environment variables with a value from `0` to `KNAPSACK_PRO_CI_NODE_TOTAL-1`. Codefresh will generate a matrix of parallel jobs where each job has a different value for `KNAPSACK_PRO_CI_NODE_INDEX`. Thanks to that Knapsack Pro knows what tests should be run on each parallel job.

Below you can find Codefresh YAML config and `Test.Dockerfile` used by Codefresh to run Ruby on Rails project with PostgreSQL inside of Docker container.

```yaml
# .codefresh/codefresh.yml
version: "1.0"

stages:
  - "clone"
  - "build"
  - "tests"

steps:
  main_clone:
    type: "git-clone"
    description: "Cloning main repository..."
    repo: "${{CF_REPO_OWNER}}/${{CF_REPO_NAME}}"
    revision: "${{CF_BRANCH}}"
    stage: "clone"
  BuildTestDockerImage:
    title: Building Test Docker image
    type: build
    arguments:
      image_name: '${{CF_ACCOUNT}}/${{CF_REPO_NAME}}-test'
      tag: '${{CF_BRANCH_TAG_NORMALIZED}}-${{CF_SHORT_REVISION}}'
      dockerfile: Test.Dockerfile
    stage: "build"

  run_tests:
    stage: "tests"
    image: '${{BuildTestDockerImage}}'
    working_directory: /src
    fail_fast: false
    environment:
      - RAILS_ENV=test
      # set how many parallel jobs you want to run
      - KNAPSACK_PRO_CI_NODE_TOTAL=2
      - PGHOST=postgres
      - PGUSER=rails-app-with-knapsack_pro
      - PGPASSWORD=password
    services:
      composition:
        postgres:
          image: postgres:latest
          environment:
            - POSTGRES_DB=rails-app-with-knapsack_pro_test
            - POSTGRES_PASSWORD=password
            - POSTGRES_USER=rails-app-with-knapsack_pro
          ports:
            - 5432
    matrix:
      environment:
        # please ensure you have here listed N-1 indexes
        # where N is KNAPSACK_PRO_CI_NODE_TOTAL
        - KNAPSACK_PRO_CI_NODE_INDEX=0
        - KNAPSACK_PRO_CI_NODE_INDEX=1
    commands:
      - bin/rails db:prepare

      # run tests in Knapsack Pro Regular Mode
      - bundle exec rake knapsack_pro:rspec
      - bundle exec rake knapsack_pro:cucumber
      - bundle exec rake knapsack_pro:minitest
      - bundle exec rake knapsack_pro:test_unit
      - bundle exec rake knapsack_pro:spinach

      # you can use Knapsack Pro in Queue Mode once recorded first CI build with Regular Mode
      - bundle exec rake knapsack_pro:queue:rspec
      - bundle exec rake knapsack_pro:queue:cucumber
      - bundle exec rake knapsack_pro:queue:minitest
```

Add `Test.Dockerfile` to your project repository.

```Dockerfile
# Test.Dockerfile
FROM ruby:2.6.5-alpine3.10

# Prepare Docker image for Nokogiri
RUN apk add --update \
  build-base \
  libxml2-dev \
  libxslt-dev \
  jq \
  nodejs \
  npm \
  postgresql-dev \
  python3-dev \
  sqlite-dev \
  git \
  && rm -rf /var/cache/apk/*

# Install AWS CLI
RUN pip3 install awscli

# Use libxml2, libxslt a packages from alpine for building nokogiri
RUN bundle config build.nokogiri --use-system-libraries

# Install Codefresh CLI
RUN wget https://github.com/codefresh-io/cli/releases/download/v0.31.1/codefresh-v0.31.1-alpine-x64.tar.gz
RUN tar -xf codefresh-v0.31.1-alpine-x64.tar.gz -C /usr/local/bin/

COPY . /src

WORKDIR /src

RUN bundle install
```

## FAQ

### Common problems

#### Why I see API error commit_hash parameter is required?

    ERROR -- : [knapsack_pro] {"errors"=>[{"commit_hash"=>["parameter is required"]}]}

When Knapsack Pro API returns error like above the problem is because you use CI provider not supported by knapsack_pro which means
knapsack_pro gem cannot determine the git commit hash and branch name. To fix this problem you can do:

* if you have git installed on CI node then you can use it to determine git commit hash and branch name. [See this](#when-should-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported)
* if you have no git installed on CI node then you should manually set `KNAPSACK_PRO_BRANCH` and `KNAPSACK_PRO_COMMIT_HASH`. For instance this might be useful when you use Jenkins. [See this](#when-you-not-set-global-variable-knapsack_pro_repository_adapter-default)

#### Why I see `LoadError: cannot load such file -- spec_helper`?

When your tests fails with:

    LoadError: cannot load such file -- spec_helper

then problem might be related to the fact you specified complex `KNAPSACK_PRO_TEST_FILE_PATTERN` and knapsack_pro gem cannot detect correct main test directory with spec_helper. You should set `KNAPSACK_PRO_TEST_DIR=spec`. Please [read also example](#how-can-i-run-tests-from-multiple-directories).

#### Why my CI build fails when I use Test::Unit even when all tests passed?

Please ensure you are actually using only Test::Unit runner. You may use some hybrid of Test::Unit and Minitest. Ensure you are not loading Minitest.

#### Why I see HEAD as branch name in user dashboard for Build metrics for my API token?

knapsack_pro detects your branch name from environment variables of [supported CI providers](#supported-ci-providers). Sometimes the CI provider may expose the `HEAD` instead of branch name (for instance for pull request merge commits).

The same can happen for CI provider not supported by default by knapsack_pro when you use [KNAPSACK_PRO_REPOSITORY_ADAPTER=git](#when-should-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported) to use local git installed on CI node to detect the branch name and git commit.

knapsack_pro uses git command `git -C /home/user/project_dir rev-parse --abbrev-ref HEAD` to detect branch name. See [source of knapsack_pro](https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/lib/knapsack_pro/repository_adapters/git_adapter.rb). In most of cases it's good way to detect branch name. But if your CI provider during CI build checkouts to specific git commit then git cannot provide the name of the branch. In such scenario you would see `HEAD` as your branch name. It is good enough situation and knapsack_pro will work correctly. The benefit of knowing exactly the branch name allows KnapsackPro API to better track history of test files timing changes across branches in order to better do split of test suite. The difference should be rather very small so it's not a problem that you have `HEAD` as branch name.

If you would like to see exact branch name instead of `HEAD` in your `build metrics` history in [user dashboard](https://knapsackpro.com/dashboard) then you can explicitly provide the branch name with `KNAPSACK_PRO_BRANCH` for each CI build.

#### Why Capybara feature tests randomly fail when using CI parallelisation?

It can happen that when you use CI parallelisation then your CI machine is overloaded and some of Capybara feature specs may randomly fail when tested website loaded slowly.

You can try to increase default Capybara max wait time from 2 seconds to something bigger like 5 seconds to ensure the Capybara will wait longer till the website is loaded before marking test as failed.

```ruby
# spec/rails_helper.rb
Capybara.default_max_wait_time = 5 # in seconds
```

For instance, this tip might be helpful for Heroku CI users who use Heroku dynos with lower performance.

#### Why knapsack_pro freezes / hangs my CI (for instance Travis)?

[Freeze error can occur for example on Travis CI](https://docs.travis-ci.com/user/common-build-problems/#ruby-tests-frozen-and-cancelled-after-10-minute-log-silence).
The `timecop` gem can result in sporadic freezing due to issues with ordering calls of `Timecop.return`, `Timecop.freeze`, and `Timecop.travel`. For instance, if using RSpec, ensure to have a `Timecop.return` configured to run after all examples:

```ruby
# in, e.g. spec/spec_helper.rb
RSpec.configure do |c|
  c.after(:all) do
    Timecop.return
  end
end
```

#### Why tests hitting external API fail?

If you use knapsack_pro and you have tests that do real HTTP requests to external API you need to ensure your tests can be run across parallel CI nodes.

Let's say you have tests that do requests to Stripe API or any other API. Before running each test you want to make sure Stripe Sandbox is clean up so you have removed all fake subscriptions and customers from Stripe Sandbox.

```ruby
# RSpec hook
before(:each) do
  Stripe::Subscription.all.each { |sub| sub.delete }
  Stripe::Customer.all.each { |customer| customer.delete }
end
```

But this will cause a problem when 2 different test files will run on 2 different CI nodes at the same time and this hook will be called. You will remove subscriptions and customers while another parallel test was running. Simply speaking you have tests that are written in a way that you can't run them in parallel.

To fix that you can think of:
* using [VCR](https://github.com/vcr/vcr) gem to record HTTP requests and then instead of doing real HTTP requests just reply recorded requests.
* maybe you could write your tests in a way when you generate some fake customers or subscriptions with fake id and each test has different customer id so there will be no conflict when 2 tests are run at the same time.

#### Why green test suite for Cucumber 2.99 tests always fails with `invalid option: --require`?

If you use old Cucumber version 2.99 and `cucumber-rails` gem you could notice bug that knapsack_pro for Cucumber fails with `1` exit status. Error you may see:

```
invalid option: --require

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!

# exit status is 1 - which means failed tests
> echo $?
1
```

The root problem is that Rails add `minitest` gem and it is started when `cucumber/rails` is loaded. It should not be. You can fix it by adding below in file `features/support/env.rb`:

```ruby
# features/support/env.rb
require 'cucumber/rails'

# this must be after we require cucumber/rails
require 'multi_test'
MultiTest.disable_autorun
```

The solution comes from: [cucumber/multi_test](https://github.com/cucumber/multi_test/pull/2#issuecomment-21863459)

#### Queue Mode problems

##### Why when I use Queue Mode for RSpec then my tests fail?

knapsack_pro Queue Mode uses `RSpec::Core::Runner` feature that allows [running specs multiple times with different runner options in the same process](https://relishapp.com/rspec/rspec-core/docs/running-specs-multiple-times-with-different-runner-options-in-the-same-process).
Thanks to that we can run subset of test suite pulled from Knapsack Pro API work queue. This allows dynamic allocation of your tests across CI nodes without reloading whole Ruby/Rails application for each run of test suite subset.

If you have custom things that are not common in how typical RSpec spec looks like then the RSpec feature won't be able to handle it between test suite subset runs.
In that case you need to resolve failed tests in a way that allows RSpec to run the tests. Feel free to [ask me for help](https://knapsackpro.com/contact).

You can learn more about [recent RSpec team changes](https://github.com/KnapsackPro/knapsack_pro-ruby/pull/42) that was backported into knapsack_pro.

To solve failing tests in Queue Mode you can check:

* you use full namespacing. If you see error like `NameError: uninitialized constant MyModule::ModelName` then in some cases a top-level constant would be matched if the code hadn't been loaded for the scoped constant. Try to use full namespacing `::SomeModule::MyModule::ModelName` etc.
* you can try to use binary version of knapsack_pro instead of running it via rake task. This helps if your rake tasks mess up with tests and make knapsack_pro Queue Mode fail. [See example](#why-when-i-use-queue-mode-for-rspec-then-factorybotfactorygirl-tests-fail):

    ```bash
    # Knapsack Pro Queue Mode run via binary
    bundle exec knapsack_pro queue:rspec "--profile 10 --format progress"
    ```

* You can check below questions for common reasons of failing tests in Queue Mode

##### Why when I use Queue Mode for RSpec then FactoryBot/FactoryGirl tests fail?

You can use [knapsack_pro binary](#knapsack-pro-binary) instead of rake task version to solve problem:

```bash
# knapsack_pro binary for Queue Mode
$ bundle exec knapsack_pro queue:rspec
```

Other solution is to check if your factories for FactoryBot/FactoryGirl use the same methods as Rake DSL and remove problematic part of the code.

The use of implicit association `task` can cause a problem.

```ruby
# won't work in knapsack_pro Queue Mode
FactoryBot.define do
  factory :assignment do
    task
  end
end
```

Workaround is to replace `task` with explicit association:

```ruby
# this will work in knapsack_pro Queue Mode
FactoryBot.define do
  factory :assignment do
    association :task
  end
end
```

##### Why when I use Queue Mode for RSpec then my rake tasks are run twice?

Why rake tasks are being ran twice in Queue Mode? If you have tests for your rake task then you want to ensure you clear the rake task before loading it inside of test file.
In Queue Mode the  rake task could be already loaded and loading it again in test file may result in running the task twice.

```ruby
before do
  # Clear rake task from memory if it was already loaded.
  # This ensures rake task is loaded only once in knapsack_pro Queue Mode.
  Rake::Task[task_name].clear if Rake::Task.task_defined?(task_name)

  # loaad rake task only once here
  Rake.application.rake_require("tasks/dummy")
  Rake::Task.define_task(:environment)
end
```

Here is the full [example how to test rake task along with dummy rake task](https://github.com/KnapsackPro/rails-app-with-knapsack_pro/commit/9f068e900deb3554bd72633e8d61c1cc7f740306) from our example rails project.

##### Why when I use Queue Mode for RSpec then I see error `superclass mismatch for class`?

You may see error like:

```
TypeError:
  superclass mismatch for class BatchClass
```

when you have 2 test files like this one:

```ruby
# spec/a_spec.rb
class BaseBatchClass
end

module Mock
  module FakeModels
    class BatchClass < BaseBatchClass
      def args
      end
    end
  end
end

describe 'A test of something' do
  it do
  end
end
```

```ruby
# spec/b_spec.rb
class DifferentBaseBatchClass
end

module Mock
  module FakeModels
    # Note the base class is different here!
    class BatchClass < DifferentBaseBatchClass
      def args
      end
    end
  end
end

describe 'B test of something' do
  it do
  end
end
```

Instead of mocking like shown above you could use [RSpec stub_const](https://relishapp.com/rspec/rspec-mocks/docs/mutating-constants) to solve error `superclass mismatch for class BatchClass`.

##### Why when I use Queue Mode for RSpec then `.rspec` config is ignored?

The `.rspec` config file is ignored in Queue Mode because knapsack_pro has to pass explicitly arguments to `RSpec::Core::Runner` underhood. You can set your arguments from `.rspec` file in an inline way.

```
bundle exec rake "knapsack_pro:queue:rspec[--format documentation --require rails_helper]"
```

See [passing arguments to RSpec](#passing-arguments-to-rspec).

##### Why I don't see collected time execution data for my build in user dashboard?

If you go to [user dashboard](https://knapsackpro.com/dashboard) and open `Build metrics` for your API token and you open build for your last git commit you should see there info about collected time execution data from all CI nodes. If you don't see collected time execution data for CI nodes then please ensure:

* you have `Knapsack::Adapters::RspecAdapter.bind` in your `rails_helper.rb` or `spec_helper.rb`
* you explicitly set `RAILS_ENV=test` on your CI nodes (for instance you use Docker then please set `RAILS_ENV`)
* knapsack_pro Queue Mode saves temporary files with collected time execution data in `your_rails_project/tmp/knapsack_pro/queue/`. Please ensure you don't clean `tmp` directory in your tests so knapsack_pro can publish time execution data to Knapsack Pro API server.

##### Why all test files have 0.1s time execution for my CI build in user dashboard?

If you go to [user dashboard](https://knapsackpro.com/dashboard) and open `Build metrics` for your API token and you open CI build for your last git commit you should see there info about collected time execution data from all CI nodes. If you see all test files have 0.1s time execution then please ensure:

* you should not clean up `tmp` directory in your tests (for instance in RSpec hooks like `before` or `after`) so knapsack_pro can publish measured time execution data to Knapsack Pro API server. knapsack_pro Queue Mode saves temporary files with collected time execution data in `your_rails_project/tmp/knapsack_pro/queue/`.
* please ensure you have in your `rails_helper.rb` or `spec_helper.rb` line that allows to measure tests:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::RSpecAdapter.bind
```

The 0.1s is a default time execution used when test file is an empty file or its content are all pending tests.

##### Why when I use Queue Mode for RSpec and test fails then I see multiple times info about failed test in RSpec result?

The problem may happen when you use old knapsack_pro `< 0.33.0` or if you use custom rspec formatter, or when you set flag [KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false](#knapsack_pro_modify_default_rspec_formatters-hide-duplicated-summary-of-pending-and-failed-tests).

When you use Queue Mode then knapsack_pro does multiple requests to Knapsack Pro API and fetches a few test files to execute.
This means RSpec will remember failed tests so far and it will present them at the end of each executed test subset if flag `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false`.
You can see the list of all failed test files at the end of knapsack_pro queue mode command.

##### Why when I use Queue Mode for RSpec then I see multiple times the same pending tests?

The problem may happen when you use old knapsack_pro `< 0.33.0` or if you use custom rspec formatter, or when you set flag [KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false](#knapsack_pro_modify_default_rspec_formatters-hide-duplicated-summary-of-pending-and-failed-tests).

When you use Queue Mode then knapsack_pro does multiple requests to Knapsack Pro API and fetches a few test files to execute.
This means RSpec will remember pending tests so far and it will present them at the end of each executed test subset if flag `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS=false`.
You can see the list of all pending test files at the end of knapsack_pro queue mode command.

##### Does in Queue Mode the RSpec is initialized many times that causes Rails load over and over again?

No. In Queue Mode the RSpec configuration is updated every time when knapsack_pro gem gets a new set of test files from the Knapsack Pro API and it looks in knapsack_pro output like RSpec was loaded many times but in fact, it loads your project environment only once.

##### Why my tests are executed twice in queue mode? Why CI node runs whole test suite again?

This may happen when you use not supported CI provider by knapsack_pro. It's because of missing value of CI build ID. You can set unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` for each CI build. The problem with test suite run again happens when one of your CI node started work later when all other CI nodes already executed whole test suite.
The slow CI node that started work late will initialize a new queue hence the tests executed twice.

To solve this problem you can set `KNAPSACK_PRO_CI_NODE_BUILD_ID` as mentioned above or you can set `KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`.
Please [read this](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

##### How to fix capybara-screenshot fail with `SystemStackError: stack level too deep` when using Queue Mode for RSpec?

Please use fixed version of capybara-screenshot.

```ruby
# Gemfile
group :test do
  gem 'capybara-screenshot', github: 'mattheworiordan/capybara-screenshot', branch: 'master'
end
```

Here is [fix PR](https://github.com/mattheworiordan/capybara-screenshot/pull/205) to official capybara-screenshot repository and the explanation of the problem.

##### Parallel tests Cucumber and RSpec with Cucumber failures exit CI node early leaving fewer CI nodes to finish RSpec Queue.

If you run tests in 2 steps like:

* Step 1. `bundle exec rake knapsack_pro:cucumber` (regular mode)
* Step 2. `bundle exec rake knapsack_pro:queue:rspec` (queue mode)

and your CI provider is configured to fail fast when one of the steps fails then in the case when the first step with Cucumber fails on one of CI nodes then the second step with RSpec in Queue Mode won't start on the CI node that failed fast.

It means the other CI nodes that will run the second step for RSpec in Queue Mode will consume the whole RSpec Queue so your whole CI build will take more than typical CI build when all Cucumber tests are green.

You should configure your CI provider to not fail fast the Cucumber step.

CI providers tips:

* If you use CircleCI 2.0 you can use `when=always` flag. Read more [here](https://discuss.circleci.com/t/parallel-tests-cuc-rspec-w-failures-exit-early-leaving-less-workers-to-finish/18081).

##### Why when I reran the same build (same commit hash, etc) on Codeship then no tests would get executed in Queue Mode?

Codeship uses the same build ID ([`CI_BUILD_NUMBER`](https://documentation.codeship.com/basic/builds-and-configuration/set-environment-variables/#default-environment-variables)) if you re-run a build, so Codeship is not giving enough information to knapsack_pro gem that this is an independent build. Knapsack Pro API assumes you already ran tests for that build ID hence no tests were executed for reran CI build.

To fix problem you can set `KNAPSACK_PRO_CI_NODE_BUILD_ID=missing-build-id` as empty string.
This way knapsack_pro won’t use build ID provided by Codeship and each build will be treated as a unique. This should be good enough solution for most users.

There is one edge case with that solution. Please note that the knapsack_pro gem doesn't have a CI build ID in order to generate a queue for each particular CI build. This may result in two different CI builds taking tests from the same queue when CI builds are running at the same time against the same git commit.

To avoid this you should specify a unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` environment variable for each CI build. This mean that each CI node that is part of particular CI build should have the same value for `KNAPSACK_PRO_CI_NODE_BUILD_ID`.

##### Why knapsack_pro hangs / freezes / is stale i.e. for Codeship in Queue Mode?

Some users with larger projects notice that in Queue Mode knapsack_pro ruby process hangs, for instance for CodeShip CI users.

It happens due too big RSpec log output in Queue Mode. To produce less logs on output you can change log level to `KNAPSACK_PRO_LOG_LEVEL=warn`.

Learn more about [log levels](#how-can-i-change-log-level).

##### How to find seed in RSpec output when I use Queue Mode for RSpec?

In output for RSpec in knapsack_pro Queue Mode you may see message:

> INFO -- : [knapsack_pro] To retry in development the subset of tests fetched from API queue please run below command on your machine. If you use --order random then remember to add proper --seed 123 that you will find at the end of rspec command.
>
> INFO -- : [knapsack_pro] bundle exec rspec --default-path spec "spec/a_spec.rb" "spec/b_spec.rb"

The seed number is used by RSpec only when you tell it, you need to provide argument `--order random`:

```bash
bundle exec rake "knapsack_pro:queue:rspec[--order random]"
```

then in RSpec output you will see something like:

```
Randomized with seed 11055
```

You can use the seed number to run tests in development:

```bash
bundle exec rspec --seed 11055 --default-path spec "spec/a_spec.rb" "spec/b_spec.rb"
```

If you don't use RSpec argument `--order random` then you don't need to provide `--seed` number when you want to reproduce tests in development.

##### How to configure puffing-billy gem with Knapsack Pro Queue Mode?

If you use [puffing-billy](https://github.com/oesmith/puffing-billy) gem you may notice [puffing-billy may crash](https://github.com/oesmith/puffing-billy/issues/253). It happen due to the way how knapsack_pro in Queue Mode uses `RSpec::Core::Runner` ([see](#why-when-i-use-queue-mode-for-rspec-then-my-tests-fail)).

Here is a patch for puffing-billy to make it work in knapsack_pro Queue Mode:

```ruby
# rails_helper.rb or spec_helper.rb

# A patch to `puffing-billy`'s proxy so that it doesn't try to stop
# eventmachine's reactor if it's not running.
module BillyProxyPatch
  def stop
    return unless EM.reactor_running?
    super
  end
end
Billy::Proxy.prepend(BillyProxyPatch)

# A patch to `puffing-billy` to start EM if it has been stopped
Billy.module_eval do
  def self.proxy
    if @billy_proxy.nil? || !(EventMachine.reactor_running? && EventMachine.reactor_thread.alive?)
      proxy = Billy::Proxy.new
      proxy.start
      @billy_proxy = proxy
    else
      @billy_proxy
    end
  end
end

if ENV["KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC"]
  KnapsackPro::Hooks::Queue.before_queue do
    # executes before Queue Mode starts work
    Billy.proxy.start
  end

  KnapsackPro::Hooks::Queue.after_queue do
    # executes after Queue Mode finishes work
    Billy.proxy.stop
  end
end
```

### General questions

#### How to run tests for particular CI node in your development environment

##### for knapsack_pro regular mode

In your development environment you can debug tests that were run on the particular CI node.
For instance to run subset of tests for the first CI node with specified seed you can do.

```bash
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=token \
KNAPSACK_PRO_REPOSITORY_ADAPTER=git \
KNAPSACK_PRO_PROJECT_DIR=~/projects/rails-app \
KNAPSACK_PRO_CI_NODE_TOTAL=2 \
KNAPSACK_PRO_CI_NODE_INDEX=0 \
bundle exec rake "knapsack_pro:rspec[--seed 123]"
```

Above example is for RSpec. You can use respectively rake task name and token environment variable when you want to run tests for minitest, test_unit, cucumber or spinach.
It should work when all CI nodes finished work and sent time execution data to Knapsack Pro API.
You can visit [user dashboard](https://knapsackpro.com/dashboard) to preview particular CI build and ensure time execution data were collected from all CI nodes.
If at least one CI node has not sent time execution data to the Knapsack Pro API then you should check below solution.

Check test runner output on particular CI node you would like to retry in development. You should see at the beginning of rspec command an output that can
be copied and executed in development.

```
/Users/ubuntu/.rvm/gems/ruby-2.4.0/gems/rspec-core-3.4.4/exe/rspec spec/foo_spec.rb spec/bar_spec.rb --default-path spec
```

Command similar to above can be executed in your development this way:

```bash
bundle exec rspec spec/foo_spec.rb spec/bar_spec.rb --default-path spec
```

If you were running your tests with `--order random` on your CI then you can additionaly pass seed param with proper value in above command (`--seed 123`).

##### for knapsack_pro queue mode

There are a few ways to reproduce tests executed on CI node in your development environment.

* At the end of `knapsack_pro:queue:rspec` results you will find example of command that you can copy and paste to your development machine. It will run all tests executed on the CI node in a single run. I recommend this approach.

* For each intermediate request to Knapsack Pro API queue you will also find example of command to run a subset of tests fetched from API. This might be helpful when you use `--order random` for rspec and you would like to reproduce the tests with the same seed.

* You can also retry tests and record the time execution data for them again for the particular CI node. Note you must be checkout on the same branch and git commit as your CI node was.

  To retry the particular CI node do this on your machine:

  ```bash
  RACK_ENV=test \
  RAILS_ENV=test \
  KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=token \
  KNAPSACK_PRO_REPOSITORY_ADAPTER=git \
  KNAPSACK_PRO_PROJECT_DIR=~/projects/rails-app \
  KNAPSACK_PRO_CI_NODE_TOTAL=2 \
  KNAPSACK_PRO_CI_NODE_INDEX=0 \
  KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true \
  bundle exec rake "knapsack_pro:queue:rspec"
  ```

  If you were running your tests with `--order random` on your CI like this:

  ```bash
  bundle exec rake "knapsack_pro:queue:rspec[--order random]"
  ```

  Then you can find the seed number visible in rspec output:

      (...)
      Randomized with seed 123

  You can pass the seed in your local environment to reproduce the tests in the same order as they were executed on CI node:

  ```bash
  RACK_ENV=test \
  RAILS_ENV=test \
  KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=token \
  KNAPSACK_PRO_REPOSITORY_ADAPTER=git \
  KNAPSACK_PRO_PROJECT_DIR=~/projects/rails-app \
  KNAPSACK_PRO_CI_NODE_TOTAL=2 \
  KNAPSACK_PRO_CI_NODE_INDEX=0 \
  KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true \
  bundle exec rake "knapsack_pro:queue:rspec[--seed 123]"
  ```

#### What happens when Knapsack Pro API is not available/not reachable temporarily?

##### for knapsack_pro regular mode

knapsack_pro gem will retry requests to Knapsack Pro API multiple times every few seconds till it switches to fallback behavior (Fallback Mode) and it will split test files across CI nodes based on popular test directory names. When knapsack_pro starts Fallback Mode then you will see a warning in the output.

Note there is an unlikely scenario when some of the CI nodes may start in Fallback Mode but others don't and then it could happen that some of test files might be skipped. You should [read this to learn more](https://github.com/KnapsackPro/knapsack_pro-ruby/pull/124) and decide if you like to use Fallback Mode when running tests with knapsack_pro Regular Mode.

If your CI provider allows to retry only one of parallel CI nodes then please [read about this edge case as well](#required-ci-configuration-if-you-use-retry-single-failed-ci-node-feature-on-your-ci-server-when-knapsack_pro_fixed_queue_splittrue-in-queue-mode-or-knapsack_pro_fixed_test_suite_splittrue-in-regular-mode).

##### for knapsack_pro queue mode

knapsack_pro gem will retry requests to Knapsack Pro API multiple times every few seconds till it switches to fallback behavior (Fallback Mode) and it will split test files across CI nodes based on popular test directory names.

Note that if one of the CI nodes loses connection to Knapsack Pro API but others don't, then some of the test files may be executed on multiple CI nodes. **Fallback Mode guarantees each of the test files is run at least once across CI nodes when you use knapsack_pro in Queue Mode.** Thanks to that we know if the whole test suite is green or not. When knapsack_pro starts Fallback Mode then you will see a warning in the output.

If your CI provider allows to retry only one of parallel CI nodes then please [read about this edge case as well](#required-ci-configuration-if-you-use-retry-single-failed-ci-node-feature-on-your-ci-server-when-knapsack_pro_fixed_queue_splittrue-in-queue-mode-or-knapsack_pro_fixed_test_suite_splittrue-in-regular-mode).

#### How can I change log level?

You can change log level by specifying the `KNAPSACK_PRO_LOG_LEVEL` environment variable.

    KNAPSACK_PRO_LOG_LEVEL=info bundle exec rake knapsack_pro:rspec

Available values are `debug` (default), `info`, `warn`, `error` and `fatal`.

Recommended log levels you can use:

* `debug` is default log level and it is recommended to log details about requests to Knapsack Pro API. Thanks to that you can debug things or ensure everything works. For instance in [user dashboard](https://knapsackpro.com/dashboard) you can find tips referring to debug logs.
* `info` level shows message like how to retry tests in development or info why something works this way or the other (for instance why tests were not executed on the CI node). You can use `info` level when you really don't want to see all debug messages from default log level.

#### How to write knapsack_pro logs to a file?

##### set directory where to write log file (option 1 - recommended)

Set `KNAPSACK_PRO_LOG_DIR=log` environment variable in order to notify knapsack_pro gem to write logs to `log` directory instead of stdout.
If you have Rails project then this should work for you.

knapsack_pro will create a file with CI node index in name. For instance if you run tests on 2 CI nodes:

* `log/knapsack_pro_node_0.log`
* `log/knapsack_pro_node_1.log`

`KNAPSACK_PRO_LOG_DIR` has higher priority than custom log set in `rails_helper.rb` as shown below (option 2).

You can change log level with [KNAPSACK_PRO_LOG_LEVEL environment variable](#how-can-i-change-log-level).

##### set custom logger config (option 2)

In your `rails_helper.rb` you can set custom Knapsack Pro logger and write to custom log file.

```ruby
# Ensure you load Rails before using Rails const below.
# This line should be already in your rails_helper.rb
require File.expand_path('../../config/environment', __FILE__)

require 'logger'
KnapsackPro.logger = Logger.new(Rails.root.join('log', "knapsack_pro_node_#{KnapsackPro::Config::Env.ci_node_index}.log"))
KnapsackPro.logger.level = Logger::DEBUG
```

Note if you run knapsack_pro then the very first request to Knapsack Pro API still will be shown to stdout because we need to have set of test files needed to run RSpec before we load `rails_helper.rb` where the configuration of logger actually is loaded for the first time.

That is why you may prefer to use option 1 instead of this.

##### How to preserve logs on my CI after CI build completed?

Follow this tip if you use one of above options to write knapsack_pro log to the file.

If you would like to keep knapsack_pro logs after your CI build finished then you could use artifacts or some cache mechanize for your CI provider.

For instance, for [CircleCI 2.0 artifacts](https://circleci.com/docs/2.0/artifacts/) you can specify log directory:

```yaml
- run:
  name: RSpec via knapsack_pro Queue Mode
  command: |
    # export word is important here!
    export RAILS_ENV=test
    bundle exec rake "knapsack_pro:queue:rspec[--format documentation]"

- store_artifacts:
  path: log
```

Now you can preview logs in `Artifacts` tab in the Circle CI build view.

#### How to split tests based on test level instead of test file level?

If you want to split one big test file (test file with long time execution) across multiple CI nodes then you can [check this tip](#split-test-files-by-test-cases) or use other methods like:

##### A. Create multiple small test files

Create multiple small test files instead of one long running test file with many test cases.
A lot of small test files will give you better test suite split results.

##### B. Use tags to mark set of tests in particular test file

Another way is to use tags to mark subset of tests in particular test file and then split tests based on tags.

This example is for knapsack_pro Regular Mode. You can also use knapsack_pro Queue Mode with tags.

Here is example of test file with specified tags for describe groups:

```ruby
# spec/features/something_spec.rb
describe 'Feature' do
  describe 'something A', :tagA do
    it {}
    it 'another test' {}
  end

  describe 'something B', :tagB do
    it {}
  end

  describe 'something else' do
    it {}
  end
end
```

You need to create API token per each tag. In this example we need 3 different API tokens.

You need to run below commands for each CI node.

```bash
# run only tests with tagA
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tagA bundle exec rake "knapsack_pro:rspec[--tag tagA]"

# run only tests with tagB
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tagB bundle exec rake "knapsack_pro:rspec[--tag tagB]"

# run other tests without tag A & B
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tests_without_tags_A_and_B bundle exec rake "knapsack_pro:rspec[--tag ~tagA --tag ~tagB]"
```

#### How to make knapsack_pro works for forked repositories of my project?

Imagine one of the scenarios, for this example I use the Travis-CI.

* We don’t want to have secrets like the `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` in `.travis.yml` in the codebase, because that code is also distributed to clients.
* Adding it as env variables to Travis itself is tricky: It has to work for pull requests from developer’s forks into our main fork; this conflicts with the way Travis handles secrets. We also need a fallback if the token is not provided (when developers do builds within their own fork).

The solution for this problem is to set `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as env variables in Travis for our main project.
This won't be accessible on forked repositories so we will run knapsack_pro in fallback mode there.
This way forked repositories have working test suite but without optimal test suite split across CI nodes.

Create the file `bin/knapsack_pro_rspec` with executable chmod in your main project repository.
Below example is for rspec. You can change `$KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` to `$KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER` if you use cucumber etc.

```bash
#!/bin/bash
if [ "$KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC" = "" ]; then
  KNAPSACK_PRO_ENDPOINT=https://api-disabled-for-fork.knapsackpro.com \
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=disabled-for-fork \
    KNAPSACK_PRO_MAX_REQUEST_RETRIES=0 \
    bundle exec rake knapsack_pro:rspec # use Regular Mode here always
else
    # Regular Mode
    bundle exec rake knapsack_pro:rspec

    # or you can use Queue Mode instead of Regular Mode if you like
    # bundle exec rake knapsack_pro:queue:rspec
fi
```

Now you can use `bin/knapsack_pro_rspec` command instead of `bundle exec rake knapsack_pro:rspec`.
Remember to follow other steps required for your CI provider.

#### How to use junit formatter?

##### How to use junit formatter with knapsack_pro regular mode?

You can use junit formatter for rspec thanks to gem [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter).
Here you can find example how to generate `rspec.xml` file with junit format and at the same time show normal documentation format output for RSpec.

```bash
# Regular Mode
bundle exec rake "knapsack_pro:rspec[--format documentation --format RspecJunitFormatter --out tmp/rspec.xml]"
```

##### How to use junit formatter with knapsack_pro queue mode?

You can use junit formatter for rspec thanks to gem [rspec_junit_formatter](https://github.com/sj26/rspec_junit_formatter).

```bash
# Queue Mode
bundle exec rake "knapsack_pro:queue:rspec[--format documentation --format RspecJunitFormatter --out tmp/rspec.xml]"
```

The xml report will contain all tests executed across intermediate test subset runs based on work queue. You need to add after subset queue hook to rename `rspec.xml` to `rspec_final_results.xml` thanks to that the final results file will contain only single xml tag with all tests executed on the CI node. This is related to the way how queue mode works. Detailed explanation is in the [issue](https://github.com/KnapsackPro/knapsack_pro-ruby/issues/40).

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain sign ~, for instance path ~/project/tmp/rspec.xml may not work. Please use full path instead.
TMP_RSPEC_XML_REPORT = 'tmp/rspec.xml'
# move results to FINAL_RSPEC_XML_REPORT so the results won't accumulate with duplicated xml tags in TMP_RSPEC_XML_REPORT
FINAL_RSPEC_XML_REPORT = 'tmp/rspec_final_results.xml'

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  if File.exist?(TMP_RSPEC_XML_REPORT)
    FileUtils.mv(TMP_RSPEC_XML_REPORT, FINAL_RSPEC_XML_REPORT)
  end
end
```

###### How to use junit formatter with knapsack_pro queue mode when CI nodes use common local drive?

Note if you use a CI provider or your own CI solution that uses common local drive for all parallel CI nodes then above solution needs to be adjusted to produce report file with CI node index number in the file name to avoid file conflicts. Example file name with CI node index number: `tmp/rspec_final_results_N.xml`.

```bash
# Queue Mode

# must be exported to read correctly the value in below knapsack_pro command
export KNAPSACK_PRO_CI_NODE_INDEX=0
# if your CI provider exposes CI node index under other environment variable name then you could use it instead

bundle exec rake "knapsack_pro:queue:rspec[--format documentation --format RspecJunitFormatter --out tmp/rspec_$KNAPSACK_PRO_CI_NODE_INDEX.xml]"
```

In below code we use CI node index number in `TMP_RSPEC_XML_REPORT` and `FINAL_RSPEC_XML_REPORT`:

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain sign ~, for instance path ~/project/tmp/rspec.xml may not work. Please use full path instead.
TMP_RSPEC_XML_REPORT = "tmp/rspec_#{ENV['KNAPSACK_PRO_CI_NODE_INDEX']}.xml"
# move results to FINAL_RSPEC_XML_REPORT so the results won't accumulate with duplicated xml tags in TMP_RSPEC_XML_REPORT
FINAL_RSPEC_XML_REPORT = "tmp/rspec_final_results_#{ENV['KNAPSACK_PRO_CI_NODE_INDEX']}.xml"

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  if File.exist?(TMP_RSPEC_XML_REPORT)
    FileUtils.mv(TMP_RSPEC_XML_REPORT, FINAL_RSPEC_XML_REPORT)
  end
end
```

###### Why `tmp/rspec_final_results.xml` is corrupted when I use junit formatter with knapsack_pro queue mode?

The `tmp/rspec_final_results.xml` might be corrupted due syntax error in your test suite. First check if your test suite is green.
Another reason might be that you did not configure the junit formatter as shown in the example for Queue Mode. Please check above 2 questions & answers explaing that.

###### How to use junit formatter with knapsack_pro queue mode in Cucumber?

Please provide in `--out` argument directory path where xml files for each test file will be created. It must be a directory in order to work in Queue Mode because in Queue Mode the Cucumber test runner is executed multiple times.
Each time for set of tests fetched from Queue so it means multiple xml files will be created in junit format.

```bash
bundle exec rake "knapsack_pro:queue:cucumber[--format junit --out tmp/test-reports/cucumber/queue_mode/]"
```

#### How to use JSON formatter for RSpec?

##### How to use RSpec JSON formatter with knapsack_pro Queue Mode?

You need to specify `format` and `out` argument (it's important to provide both).

```bash
# Queue Mode
bundle exec rake "knapsack_pro:queue:rspec[--format documentation --format json --out tmp/rspec.json]"
```

The JSON report will contain all tests executed across intermediate test subset runs based on work queue. You need to add after subset queue hook to rename `rspec.json` to `rspec_final_results.json` thanks to that the final results file will contain valid json with all tests executed on the CI node. This is related to the way how Queue Mode works. Detailed explanation is in the [issue](https://github.com/KnapsackPro/knapsack_pro-ruby/issues/40).

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain sign ~, for instance path ~/project/tmp/rspec.json may not work. Please use full path instead.
TMP_RSPEC_JSON_REPORT = 'tmp/rspec.json'
# move results to FINAL_RSPEC_JSON_REPORT so the results won't accumulate with duplicated JSON in TMP_RSPEC_JSON_REPORT
FINAL_RSPEC_JSON_REPORT = 'tmp/rspec_final_results.json'

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  if File.exist?(TMP_RSPEC_JSON_REPORT)
    FileUtils.mv(TMP_RSPEC_JSON_REPORT, FINAL_RSPEC_JSON_REPORT)
  end
end
```

###### How to use RSpec JSON formatter with knapsack_pro Queue Mode when CI nodes use common local drive?

Note if you use a CI provider or your own CI solution that uses common local drive for all parallel CI nodes then above solution needs to be adjusted to produce report file with CI node index number in the file name to avoid file conflicts. Example file name with CI node index number: `tmp/rspec_final_results_N.json`.

```
# Queue Mode

# must be exported to read correctly the value in below knapsack_pro command
export KNAPSACK_PRO_CI_NODE_INDEX=0
# if your CI provider exposes CI node index under other environment variable name then you could use it instead

bundle exec rake "knapsack_pro:queue:rspec[--format documentation --format json --out tmp/rspec_$KNAPSACK_PRO_CI_NODE_INDEX.json]"
```

In below code we use CI node index number in `TMP_RSPEC_JSON_REPORT` and `FINAL_RSPEC_JSON_REPORT`:

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain sign ~, for instance path ~/project/tmp/rspec.json may not work. Please use full path instead.
TMP_RSPEC_JSON_REPORT = "tmp/rspec_#{ENV['KNAPSACK_PRO_CI_NODE_INDEX']}.json"
# move results to FINAL_RSPEC_JSON_REPORT so the results won't accumulate with duplicated JSON in TMP_RSPEC_JSON_REPORT
FINAL_RSPEC_JSON_REPORT = "tmp/rspec_final_results_#{ENV['KNAPSACK_PRO_CI_NODE_INDEX']}.json"

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  if File.exist?(TMP_RSPEC_JSON_REPORT)
    FileUtils.mv(TMP_RSPEC_JSON_REPORT, FINAL_RSPEC_JSON_REPORT)
  end
end
```

#### How many API keys I need?

Basically you need as many API keys as you have steps in your build.

Here is example:

* Step 1. API_KEY_A for `bundle exec rake knapsack_pro:cucumber`
* Step 2. API_KEY_B for `bundle exec rake knapsack_pro:rspec`
* Step 3. API_KEY_C for `KNAPSACK_PRO_TEST_FILE_PATTERN="spec/features/*_spec.rb" bundle exec rake knapsack_pro:rspec`
* Step 4. API_KEY_D for `bundle exec rake knapsack_pro:rspec[--tag tagA]`
* Step 5. API_KEY_E for `bundle exec rake knapsack_pro:rspec[--tag ~tagA]`
* Step 6. API_KEY_F for `bundle exec rake knapsack_pro:queue:rspec`

Note:

* If you specified `KNAPSACK_PRO_TEST_FILE_PATTERN` then you run subset of your whole test suite hence you need separate API key because we want to track only tests for this subset.
* If you pass `--tag tagA` or `--tag ~tagA` then you run subset of your whole test suite hence you need separate API key.
* If you use regular or queue mode then you need separate API key for each mode.

#### What is optimal order of test commands?

__Tip 1:__

I recommend to run first the test commands in the regular mode and later the commands in the queue mode.

  * Step 1. `bundle exec rake knapsack_pro:cucumber` (regular mode)
  * Step 2. `bundle exec rake knapsack_pro:queue:rspec` (queue mode)

Thanks to that when for some reason the tests executed for cucumber in regular mode will not be well balanced across CI nodes (for instance when one of CI node has bad performance) then the rspec tests executed later in the queue mode will autobalance your build.

__Tip 2:__

When you have short test suite, for instance in javascript then you could distribute tests this way:

* CI 0
  * Step 1: `npm test`
  * Step 2: `bundle exec rake knapsack_pro:queue:rspec`

* CI 1
  * Step 1: `bundle exec rake knapsack_pro:queue:rspec`

You will run your javascript tests on single CI node and the knapsack_pro will auto-balance CI build with Queue Mode. Thanks to that CI build time execution will be flat and optimal (as fast as possible).

#### How to set `before(:suite)` and `after(:suite)` RSpec hooks in Queue Mode (Percy.io example)?

##### percy-capybara gem version < 4 (old)

Some tools like [Percy.io](https://percy.io/docs/clients/ruby/capybara-rails) requires to set hooks for RSpec `before(:suite)` and `after(:suite)`.
Knapsack Pro Queue Mode runs subset of test files from the work queue many times. This means the RSpec hooks `before(:suite)` and `after(:suite)` will execute multiple times. If you want to run some code only once before Queue Mode starts work and after it finishes then you should do it this way:

```ruby
# spec_helper.rb or rails_helper.rb
# step for percy-capybara gem version < 4

KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  # executes before Queue Mode starts work
  Percy::Capybara.initialize_build
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  # executes after Queue Mode finishes work
  Percy::Capybara.finalize_build
end
```

##### percy-capybara gem version >= 4

If you use [percy-capybara 4.x](https://docs.percy.io/v1/docs/capybara) then you don't need to set RSpec hooks. Insted you need to run knapsack_pro via percy npm command.

```
npx percy exec -- rake knapsack_pro:queue:rspec

# or you can use knapsack_pro binary version instead of rake task
npx percy exec -- knapsack_pro queue:rspec
```

Read more about [knapsack_pro binary version](#knapsack-pro-binary).

Also you need to follow [Percy step for parallelism](https://docs.percy.io/docs/parallel-test-suites#section-manual-configuration-with-environment-variables).

* `PERCY_PARALLEL_NONCE` - A unique identifier for this build. This can be anything, but it must be the same across parallel build nodes. Usually, this is just the CI build number or a shared timestamp. You can google environment variables for CI provider you use to check what's the env var for build ID.

  You can also find CI build number for your CI provider in [knapsack_pro source code](https://github.com/KnapsackPro/knapsack_pro-ruby/tree/master/lib/knapsack_pro/config/ci). knapsack_pro has built in environment variables integration for various CI providers. See for example [CircleCI](https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/lib/knapsack_pro/config/ci/circle.rb) - look for method `node_build_id`.

  ```bash
  # example for using CircleCI build ID
  export PERCY_PARALLEL_NONCE=$CIRCLE_BUILD_NUM
  ```

* `PERCY_PARALLEL_TOTAL` - The total number of parallel build nodes.

#### How to call `before(:suite)` and `after(:suite)` RSpec hooks only once in Queue Mode?

Knapsack Pro Queue Mode runs subset of test files from the work queue many times. This means the RSpec hooks `before(:suite)` and `after(:suite)` will be executed multiple times. If you want to run some code only once before Queue Mode starts work and after it finishes then you should do it this way:

```ruby
# spec_helper.rb or rails_helper.rb

KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  # This will be called only once before the tests started on the CI node.
  # It will be run inside of the RSpec before(:suite) block only once.
  # It means you will have access to whatever RSpec provides in the context of the before(:suite) block.
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  # This will be called only once after test suite is completed.
  # Note this hook won't be called inside of RSpec after(:suite) block because
  # we are not able to determine which after(:suite) block will be called as the last one
  # due to the fact the Knapsack Pro Queue Mode allocates tests in dynamic way.
end
```

#### What hooks are supported in Queue Mode?

Note: Each hook type can be defined multiple times. For instance, if you define `KnapsackPro::Hooks::Queue.before_queue` twice then both block of code will be called when running your tests.

* RSpec in knapsack_pro Queue Mode supports hooks:

```ruby
# spec_helper.rb or rails_helper.rb
KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  print 'Before Queue Hook - run before test suite'
end

# this will be run after set of tests fetched from Queue has been executed
KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  print 'After Subset Queue Hook - run after subset of test suite'
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  print 'After Queue Hook - run after test suite'
end
```

* Minitest in knapsack_pro Queue Mode supports hooks:

```ruby
# test/test_helper.rb
KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  print 'Before Queue Hook - run before test suite'
end

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  print 'After Subset Queue Hook - run after subset of test suite'
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  print 'After Queue Hook - run after test suite'
end
```

* Cucumber in knapsack_pro Queue Mode supports hooks:

```ruby
# features/support/knapsack_pro.rb
KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  print 'Before Queue Hook - run before test suite'
end

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  print 'After Subset Queue Hook - run after subset of test suite'
end

# this hook is not supported and won't run
KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  print 'After Queue Hook - run after test suite'
end
```

#### How to run knapsack_pro with parallel_tests gem?

##### Should I use parallel_tests gem (what are pitfalls)?

If you plan to use parallel_tests please be careful how many parallel processes with running tests you will start on a single CI node.
Often it happens that running 2 or more processes with tests using parallel_tests gem on the CI node that has low performance leads to slower execution of test suite. You can accidentally make your whole test suite running slower by using parallel_tests if you have not enough powerful CI server (slow CPU, not enough RAM, slow disk).

If you use parallel_tests and knapsack_pro you can see recorded tests timing in Knapsack Pro [user dashboard](https://knapsackpro.com/dashboard). See the "Build metrics" link next to your API token and check the last recorded CI build time. You will be able to see there how long each test files took to execute. If you notice that after adding parallel_tests gem your test files started to take more time than before it means you overloaded your CI server.

You should:

* reduce the number of parallel processes in parallel_tests gem
* or buy a more powerful CI node to allow running more parallel processes (vertical scaling)
* or don't use parallel_tests gem at all (recommended)

In case of tests execution time increase (slower tests) I recommend using more parallel nodes offered by your CI provider to scale your tests horizontally. Basically, adding parallel CI nodes instead of vertically adding more CPU/RAM to CI node is a better option. Parallel_tests gem has mixed output results from the parallel processes so it's easier to just browse tests output from parallel CI nodes when you scale horizontally by using knapsack_pro without parallel_tests.

If you want to use parallel_tests you can use it with Knapsack Pro Queue Mode to auto-balance tests split across parallel processes started by parallel_tests gem. See below tips on how to do it on [many parallel CI nodes where each node starts many parallel_tests processes](#parallel_tests-with-knapsack_pro-on-parallel-ci-nodes) or [on a single powerful CI server](#parallel_tests-with-knapsack_pro-on-single-ci-machine).

##### parallel_tests with knapsack_pro on parallel CI nodes

You can run knapsack_pro with [parallel_tests](https://github.com/grosser/parallel_tests) gem to run multiple concurrent knapsack_pro commands per CI node.

Let's consider this example. We have 2 CI node. On each CI node we want to run 2 concurrent knapsack_pro commands by parallel_tests gem (`PARALLEL_TESTS_CONCURRENCY=2`).
This means we would have 4 parallel knapsack_pro commands in total across all CI nodes. So from knapsack_pro perspective you will have 4 nodes in total.

Create in your project directory an executable file `bin/parallel_tests`:

```bash
#!/bin/bash
# This file should be in bin/parallel_tests

# updates CI node total based on parallel_tests concurrency
KNAPSACK_PRO_CI_NODE_TOTAL=$(( $PARALLEL_TESTS_CONCURRENCY * $KNAPSACK_PRO_CI_NODE_TOTAL ))

if [ "$TEST_ENV_NUMBER" == "" ]; then
  PARALLEL_TESTS_CONCURRENCY_INDEX=0
else
  PARALLEL_TESTS_CONCURRENCY_INDEX=$(( $TEST_ENV_NUMBER - 1 ))
fi

KNAPSACK_PRO_CI_NODE_INDEX=$(( $PARALLEL_TESTS_CONCURRENCY_INDEX + ($PARALLEL_TESTS_CONCURRENCY * $KNAPSACK_PRO_CI_NODE_INDEX) ))

# logs info about ENVs to ensure everything works
echo KNAPSACK_PRO_CI_NODE_TOTAL=$KNAPSACK_PRO_CI_NODE_TOTAL KNAPSACK_PRO_CI_NODE_INDEX=$KNAPSACK_PRO_CI_NODE_INDEX PARALLEL_TESTS_CONCURRENCY=$PARALLEL_TESTS_CONCURRENCY

# you can customize your knapsack_pro command here to use regular or queue mode
bundle exec rake knapsack_pro:queue:rspec
```

Now you need to set parallel_tests command per CI node:

* CI node 0 (first CI node):

    ```bash
    export PARALLEL_TESTS_CONCURRENCY=2; # this must be export
    RAILS_ENV=test \
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=xxx \
    KNAPSACK_PRO_CI_NODE_TOTAL=$YOUR_CI_NODE_TOTAL \
    KNAPSACK_PRO_CI_NODE_INDEX=$YOUR_CI_NODE_INDEX \
    bundle exec parallel_test -n $PARALLEL_TESTS_CONCURRENCY -e './bin/parallel_tests'
    ```

* CI node 1 (second CI node):

    ```bash
    export PARALLEL_TESTS_CONCURRENCY=2; # this must be export
    RAILS_ENV=test \
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=xxx \
    KNAPSACK_PRO_CI_NODE_TOTAL=$YOUR_CI_NODE_TOTAL \
    KNAPSACK_PRO_CI_NODE_INDEX=$YOUR_CI_NODE_INDEX \
    bundle exec parallel_test -n $PARALLEL_TESTS_CONCURRENCY -e './bin/parallel_tests'
    ```

Please note you need to update `$YOUR_CI_NODE_TOTAL` and `$YOUR_CI_NODE_INDEX` to the ENVs provided by your CI provider. For instance in case of CircleCI it would be `$CIRCLE_NODE_TOTAL` and `$CIRCLE_NODE_INDEX`. Below is an example for CircleCI configuration:

```yaml
# circle.yml for CircleCI 1.0
# KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=xxx can be set in CircleCI ENV settings
test:
  override:
    - export PARALLEL_TESTS_CONCURRENCY=2; RAILS_ENV=test KNAPSACK_PRO_CI_NODE_TOTAL=$CIRCLE_NODE_TOTAL KNAPSACK_PRO_CI_NODE_INDEX=$CIRCLE_NODE_INDEX bundle exec parallel_test -n $PARALLEL_TESTS_CONCURRENCY -e './bin/parallel_tests':
        parallel: true # Caution: there are 8 spaces indentation!
```

In summary, the `bin/parallel_tests` script will calculate a new values for `KNAPSAKC_PRO_*` environment variables and then run knapsack_pro command with them.
To ensure everything works you can check output for each CI node.

* Expected output for CI node 0 (first CI node):

    ```
    KNAPSACK_PRO_CI_NODE_TOTAL=4 KNAPSACK_PRO_CI_NODE_INDEX=1 PARALLEL_TESTS_CONCURRENCY=2
    KNAPSACK_PRO_CI_NODE_TOTAL=4 KNAPSACK_PRO_CI_NODE_INDEX=0 PARALLEL_TESTS_CONCURRENCY=2
    (tests output here)
    ```

* Expected output for CI node 1 (second CI node):

    ```
    KNAPSACK_PRO_CI_NODE_TOTAL=4 KNAPSACK_PRO_CI_NODE_INDEX=2 PARALLEL_TESTS_CONCURRENCY=2
    KNAPSACK_PRO_CI_NODE_TOTAL=4 KNAPSACK_PRO_CI_NODE_INDEX=3 PARALLEL_TESTS_CONCURRENCY=2
    (tests output here)
    ```

##### parallel_tests with knapsack_pro on single CI machine

This tip is only relevant to you if you cannot use multiple parallel CI nodes on your CI provider. In such case, you can run your tests on a single CI machine with knapsack_pro Queue Mode in order to auto balance execution of tests and thanks to this better utilize CI machine resources.

You can run knapsack_pro with [parallel_tests](https://github.com/grosser/parallel_tests) gem to run multiple concurrent knapsack_pro commands on single CI node.

Create in your project directory an executable file `bin/parallel_tests_knapsack_pro_single_machine`:

```bash
#!/bin/bash
# bin/parallel_tests_knapsack_pro_single_machine

export KNAPSACK_PRO_CI_NODE_TOTAL=$PARALLEL_TESTS_CONCURRENCY

if [ "$TEST_ENV_NUMBER" == "" ]; then
  export KNAPSACK_PRO_CI_NODE_INDEX=0
else
  export KNAPSACK_PRO_CI_NODE_INDEX=$(( $TEST_ENV_NUMBER - 1 ))
fi

echo KNAPSACK_PRO_CI_NODE_TOTAL=$KNAPSACK_PRO_CI_NODE_TOTAL KNAPSACK_PRO_CI_NODE_INDEX=$KNAPSACK_PRO_CI_NODE_INDEX PARALLEL_TESTS_CONCURRENCY=$PARALLEL_TESTS_CONCURRENCY

bundle exec rake knapsack_pro:queue:rspec
```

Then you need another script `bin/parallel_tests_knapsack_pro_single_machine_run` to run above script with `parallel_tests`:

```bash
#!/bin/bash
# bin/parallel_tests_knapsack_pro_single_machine_run

export PARALLEL_TESTS_CONCURRENCY=2;

RAILS_ENV=test \
  KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=xxx \
  KNAPSACK_PRO_REPOSITORY_ADAPTER=git \
  KNAPSACK_PRO_PROJECT_DIR=/home/user/rails-app-repo \
  PARALLEL_TESTS_CONCURRENCY=$PARALLEL_TESTS_CONCURRENCY \
  bundle exec parallel_test -n $PARALLEL_TESTS_CONCURRENCY -e './bin/parallel_tests_knapsack_pro_single_machine'
```

Now you can run `bin/parallel_tests_knapsack_pro_single_machine_run` and it will execute 2 parallel processes with `parallel_tests`. Each process will run knapsack_pro Queue Mode to autobalance test files distribution across the processes.

#### How to retry failed tests (flaky tests)?

Flaky (nondeterministic) tests, are tests that exhibit both a passing and a failing result with the same code.

I recommend to use [rspec-retry](https://github.com/NoRedInk/rspec-retry) gem that can retry failing test. It can be useful for randomly failing features specs. For instance you can configure it to retry 3 times features test before marking it as failing.

Alternative way is to use built into [RSpec only failures option](https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures) to rerun failed tests.

Please add to your RSpec configuration:

```ruby
RSpec.configure do |c|
  c.example_status_persistence_file_path = "tmp/rspec_examples.txt"
end
```

Then you can execute rspec with only failed tests after main knapsack_pro command finish.

```bash
# Run knapsack_pro in Queue Mode and it will save failed tests in tmp/rspec_examples.txt
bundle exec rake knapsack_pro:queue:rspec

# run only failed tests from tmp/rspec_examples.txt
bundle exec rspec --only-failures
```

#### How can I run tests from multiple directories?

The test file pattern config option supports any glob pattern handled by [`Dir.glob`](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob) and can be configured to pull test files from multiple directories. An example of this when using RSpec would be `"{spec,engines/*/spec}/**/*_spec.rb"`. For complex cases like this, the test directory can't be extracted and must be specified manually using the `KNAPSACK_PRO_TEST_DIR` environment variable:

```
# This is example where you have in engines directory multiple projects
# and each project directory has a spec folder and you would like to run tests for it.
# You want to use the spec_helper from the main spec directory.
#
# Tree:
# * spec
# * engines
#   * project_a
#     * spec
#   * project_b
#     * spec
$ KNAPSACK_PRO_TEST_DIR=spec KNAPSACK_PRO_TEST_FILE_PATTERN="{spec,engines/*/spec}/**/*_spec.rb" bundle exec rake knapsack_pro:queue:rspec
```

`KNAPSACK_PRO_TEST_DIR` will be your default path for rspec so you should put there your `spec_helper.rb`. Please ensure you will require it in your test files this way if something doesn't work:

```ruby
# good
require_relative 'spec_helper'

# bad - won't work
require 'spec_helper'
```

#### Why I don't see all test files being recorded in user dashboard

If you open `Build metrics` for particular API token at [user dashboard](https://knapsackpro.com/dashboard) and you don't see all time execution data recorded for all test files then you should know that knapsack_pro version older than [`1.0.2`](https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/CHANGELOG.md#102) does not track test files with empty content or when the test file contains only pending tests.

The test files with pending tests are executed so you will see it in RSpec output but just not recorded in Knapsack Pro API because there is nothing to record time for.

We recommend to update to the latest version of knapsack_pro.

Please check also this question [why you may don't see time execution data](#why-i-dont-see-collected-time-execution-data-for-my-build-in-user-dashboard) in your dashboard.

#### Why when I use 2 different CI providers then not all test files are executed?

Please ensure you use 2 different API token per test suite. If you use 2 CI providers for instance CircleCI and TravisCI at the same time and you run the RSpec test suite then you need to have separate API token for RSpec executed on CircleCI and a separate API token for RSpec test suite executed on the TravisCI.

#### How to run only RSpec feature tests or non feature tests?

**Option 1: RSpec tags**

You can run just feature tests this way. You need to generate a separate API token for it.

```
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=$API_TOKEN_FOR_FEATURE_TESTS bundle exec rake "knapsack_pro:queue:rspec[--tag type:feature]"
```

If you would like to run only non feature tests then use negation `~type:feature`:

```
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=$API_TOKEN_FOR_NON_FEATURE_TESTS bundle exec rake "knapsack_pro:queue:rspec[--tag ~type:feature]"
```

Note above examples are for knapsack_pro Queue Mode and when you will run tests you may notice that all test files are run by RSpec but only tests specified by tag like `tag type:feature` will be executed. Basically RSpec will just load all files but run just specified tags.

**Option 2: specify directory pattern**

Another approach is to explicitly specify which files should be executed.

Run all specs from multiple directories except `spec/features` directory which is not listed below.
If you would like to run additional directory please add it after comma in `KNAPSACK_PRO_TEST_FILE_PATTERN`.
Ensure the list of directories match your spec directory structure.

```bash
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=$API_TOKEN_FOR_NON_FEATURE_TESTS \
KNAPSACK_PRO_TEST_DIR=spec \
KNAPSACK_PRO_TEST_FILE_PATTERN="{spec/*_spec.rb,spec/controllers/**/*_spec.rb,spec/mailers/**/*_spec.rb,spec/models/**/*_spec.rb,spec/presenters/**/*_spec.rb,spec/requests/**/*_spec.rb,spec/routing/**/*_spec.rb,spec/services/**/*_spec.rb,spec/workers/**/*_spec.rb,spec/jobs/**/*_spec.rb}" \
bundle exec rake knapsack_pro:queue:rspec
```

When you would like to run tests only from `spec/features` directory then run:

```bash
KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=$API_TOKEN_FOR_FEATURE_TESTS \
KNAPSACK_PRO_TEST_DIR=spec \
KNAPSACK_PRO_TEST_FILE_PATTERN="spec/features/**{,/*/**}/*_spec.rb" \
bundle exec rake knapsack_pro:queue:rspec
```

You can also learn [how to use exclude pattern](#how-to-exclude-tests-from-running-them).

#### How to exclude tests from running them?

For instance you would like to run all tests except tests in `features` directory then you could do:

```bash
KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN="spec/features/**{,/*/**}/*_spec.rb" \
bundle exec rake knapsack_pro:queue:rspec
```

You can define at the same time the pattern for tests you would like to run and the exclude pattern. For instance run all controller tests except admin controller tests.

```bash
KNAPSACK_PRO_TEST_FILE_PATTERN="spec/controllers/**{,/*/**}/*_spec.rb" \
KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN="spec/controllers/admin/**{,/*/**}/*_spec.rb" \
bundle exec rake knapsack_pro:queue:rspec
```

The test file pattern and exclude pattern support any glob pattern handled by [`Dir.glob`](http://ruby-doc.org/core-2.4.1/Dir.html#method-c-glob).

#### How to run a specific list of test files or only some tests from test file?

:information_source: If you don't want to use the pattern [`KNAPSACK_PRO_TEST_FILE_PATTERN`](#how-can-i-run-tests-from-multiple-directories) to define a list of tests to run then read below two options.

**Option 1:**  

If you want to run a specific list of test files that are explicitly defined by you or auto-generated by some kind of script you created then please use:

`KNAPSACK_PRO_TEST_FILE_LIST=spec/features/dashboard_spec.rb,spec/models/user.rb:10,spec/models/user.rb:29`

Note `KNAPSACK_PRO_TEST_FILE_LIST` must be a list of test files comma separated. You can provide line number for tests inside of spec file in case of RSpec (this way you can run only one test or a group of tests from RSpec spec file). You can provide the same file a few times with different test line number.

**Option 2:** 

Similarly, you can also provide a source file containing the test files that you would like to run. For example:
`KNAPSACK_PRO_TEST_FILE_LIST_SOURCE_FILE=spec/fixtures/test_file_list_source_file.txt`  
And the content of the source file can be any of the format below:

```
./spec/test1_spec.rb
spec/test2_spec.rb[1]
./spec/test3_spec.rb[1:2:3:4]
./spec/test4_spec.rb:4
./spec/test4_spec.rb:5
```

> Note that each of the line must be ending with `\n` the new line.

Note when you set `KNAPSACK_PRO_TEST_FILE_LIST` or `KNAPSACK_PRO_TEST_FILE_LIST_SOURCE_FILE` then below environment variables are ignored:

* `KNAPSACK_PRO_TEST_FILE_PATTERN`
* `KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN`

#### How to run knapsack_pro only on a few parallel CI nodes instead of all?

You may want to run knapsack_pro only on a few CI nodes when you would like to run a different job on other CI nodes.

For instance, you have 3 parallel CI nodes. You would like to run knapsack_pro only on two CI nodes. The last CI node you want to use for the different job like running linters etc.

In such case, you can override the number of total CI nodes available by your CI provider. For instance, Heroku CI provider exposes in ENV variables `CI_NODE_TOTAL=3`.

You can then run knapsack_pro command this way on the first and the second CI node:

```
KNAPSACK_PRO_CI_NODE_TOTAL=$((CI_NODE_TOTAL-1)) bundle exec rake knapsack_pro:rspec
```

We decrease the number of CI node total by 1 that knapsack_pro can see. This way you can run tests with knapsack_pro only on two CI nodes.
On the 3rd CI node, you can run other things like linters etc.

If you would like to check what is the CI node total ENV variable name exposed by your CI provider you can check that in your CI provider environment variables docs
or preview the [ENV variables that knapsack_pro can read](https://github.com/KnapsackPro/knapsack_pro-ruby/tree/master/lib/knapsack_pro/config/ci) for supported CI providers.

If you use for instance Heroku CI that allows you to provide only one test command you can make a bash script to control what's executed on particular CI node:

```bash
#!/bin/bash
# add this file in bin/knapsack_pro_rspec_and_npm_test and change chmod
# $ chmod a+x bin/knapsack_pro_rspec_and_npm_test

# 15 is last CI node (index starts from 0, so in total we have 16 parallel Heroku dynos)
if [ "$CI_NODE_INDEX" == "15" ]; then
  # run npm tests on the last CI node
  npm test
else
  KNAPSACK_PRO_CI_NODE_TOTAL=$((CI_NODE_TOTAL-1)) bundle exec rake knapsack_pro:queue:rspec
fi
```

then in your Heroku CI config `app.json` set:

```
"scripts": {
  "test": "bin/knapsack_pro_rspec_and_npm_test"
}
```

#### How to use CodeClimate with knapsack_pro?

You can check articles about CodeClimate configuration with knapsack_pro gem:
* [CodeClimate and CircleCI 2.0 parallel builds config for RSpec with SimpleCov and JUnit formatter](https://docs.knapsackpro.com/2019/codeclimate-and-circleci-2-0-parallel-builds-config-for-rspec-with-simplecov-and-junit-formatter)
* [How to merge CodeClimate reports for parallel jobs (CI nodes) on Semaphore CI 2.0](https://docs.knapsackpro.com/2019/how-to-merge-codeclimate-reports-for-parallel-jobs-ci-nodes).

#### How to use simplecov in Queue Mode?

If you would like to make [simplecov](https://github.com/colszowka/simplecov) gem work with knapsack_pro Queue Mode to correctly track code coverage for parallel CI nodes please do:

```ruby
# spec_helper.rb or rails_helper.rb
require 'knapsack_pro'

require 'simplecov'
SimpleCov.start

KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  SimpleCov.command_name("rspec_ci_node_#{KnapsackPro::Config::Env.ci_node_index}")
end
```

This way there should be no conflict between code coverage reports generated per CI node index even when you use the same local drive (for instance you use Jenkins as your CI provider). The simplecov will generate single report at `coverage/index.html` with merged data from parallel CI nodes.

#### Do I need to use separate API token for Queue Mode and Regular Mode?

I recommend to record timing of a new test suite with `API token A` and knapsack_pro Regular Mode. After you recorded test suite timing then you should use the `API token A` to run your tests in knapsack_pro Queue Mode. This way Queue Mode will leverage test suite timing recorded in a fast way with Regular Mode so the first run in Queue Mode won't be slow due to recording test files timing for the first time.

When you want to go back from Queue Mode to Regular Mode then the fact of using the same API token could cause edge cases that some builds might not be well balanced in Regular Mode. That is why I recommend using separate API token for Regular Mode and Queue Mode. If you plan to use only Queue Mode then no worry.

#### How to stop running tests on the first failed test (fail fast tests in RSpec)?

If you want to stop running tests as soon as one of it fails then you can pass [--fail-fast](https://relishapp.com/rspec/rspec-core/docs/command-line/fail-fast-option) RSpec option to knapsack_pro:

```
# Regular Mode
bundle exec rake "knapsack_pro:rspec[--fail-fast]"

# Queue Mode
bundle exec rake "knapsack_pro:queue:rspec[--fail-fast]"
```

You may add a parameter to tell RSpec to stop running the test suite after N failed tests, for example: `--fail-fast=3`.

```
Note there is no = sign on purpose here:

# Regular Mode
bundle exec rake "knapsack_pro:rspec[--fail-fast 3]"

# Queue Mode
bundle exec rake "knapsack_pro:queue:rspec[--fail-fast 3]"
```

There is a downside to it. If you stop running tests then tests that were never run will have no recorded timing of execution and because of that, the future CI build might have tests split across CI nodes in no optimal way.

### Questions around data usage and security

#### What data is sent to your servers?

The knapsack_pro gem sends branch name, commit hash, CI total node number, CI index node number, the test file paths like `spec/models/user_spec.rb` and the time execution of each test file path as a float.

Here is the [full specification of the API](http://docs.knapsackpro.com/api/v1/) used by knapsack_pro gem.

#### How is that data secured?

The test file paths and/or branch names can be [encrypted](#test-file-names-encryption) on your CI node with a salt and later send to knapsackpro.com API.
You generate the salt locally and __only you__ can decrypt the test file paths or branch names with the salt. Here you can [see how the data are encrypted](lib/knapsack_pro/crypto/digestor.rb).

Connection with knapsackpro.com server is via https.

Regarding payments we use the BraintreePayments.com and they store credit cards and your private information.

#### Who has access to the data?

I’m the only admin so I can preview data in case you need help with debugging some problem etc. I’m not able to decrypt them without knowing the salt.

When you sign in to your user dashboard then you can preview data for recent CI builds. If the test file paths are encrypted then you only see hashes for test file paths.
You need to [decrypt](#how-to-debug-test-file-names) them locally on your machine to find out what each test file hash is.

## Gem tests

### Spec

To run specs for Knapsack Pro gem type:

    $ bundle exec rspec spec

## Contributing

1. Fork it ( https://github.com/KnapsackPro/knapsack_pro-ruby )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. You can create example tests in related repository with example of [rails application and knapsack_pro gem usage](https://github.com/KnapsackPro/rails-app-with-knapsack_pro).
6. Create a new Pull Request

### Publishing

Update version in `lib/knapsack_pro/version.rb` and `CHANGELOG.md`:

```
$ git commit -m "Bump version X.X.X"
$ git push origin master
```

Create git tag for release:

```
$ git tag -a vX.X.X -m "Release vX.X.X"
$ git push --tags
```

Build gem and publish it to RubyGems.org:

```
$ gem build knapsack_pro.gemspec
$ gem push knapsack_pro-X.X.X.gem
```

Update the latest available gem version in `TestSuiteClientVersionChecker` for the Knapsack Pro API repository.

## Mentions

List of articles where people mentioned Knapsack Pro:

* [Treat your Build Pipeline as a Product](https://medium.com/mydr-engineering/treat-your-build-pipeline-as-a-product-61a1b24ae538).
  * Video - [Your Build Pipeline is a Product](https://www.youtube.com/watch?v=7e8Qk3H6xhg&t=21m14s)
