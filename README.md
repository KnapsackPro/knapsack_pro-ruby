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

[FAQ for knapsack_pro gem can be found here](https://knapsackpro.com/faq/knapsack_pro_client/knapsack_pro_ruby).

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

Debug is default log level and it is recommended. [Read more](https://knapsackpro.com/faq/question/how-can-i-change-log-level).

Note your own logger is configured in `spec_helper.rb` or `rails_helper.rb` and it will start working when those files will be loaded.
It means the very first request to Knapsack Pro API will be log to `STDOUT` using logger built into knapsack_pro instead of your custom logger.

If you want to change log level globally than just for your custom log level, please [see this](https://knapsackpro.com/faq/question/how-can-i-change-log-level).

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

__Tip 2:__ If you use one of unsupported CI providers ([here is list of supported CI providers](#supported-ci-providers)) then you should [set KNAPSACK_PRO_REPOSITORY_ADAPTER=git](#when-should-you-set-global-variable-knapsack_pro_repository_adaptergit-when-ci-provider-is-not-supported-and-you-use-git).

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

If you use the capybara-screenshot gem then please [follow this step](https://knapsackpro.com/faq/question/how-to-fix-capybara-screenshot-fail-with-systemstackerror-stack-level-too-deep-when-using-queue-mode-for-rspec).

If you use the rspec_junit_formatter gem then please [follow this step](https://knapsackpro.com/faq/question/how-to-use-junit-formatter#how-to-use-junit-formatter-with-knapsack_pro-queue-mode).

If your test suite is very long and the RSpec output is too long for your CI node then you can set log level `KNAPSACK_PRO_LOG_LEVEL=info` to don't show debug messages in RSpec output. [Read more about log level](https://knapsackpro.com/faq/question/how-can-i-change-log-level).

### Additional info about queue mode

* You should use a separate API token for queue mode than for regular mode to avoid problems with test suite split (especially in case you would like to go back to regular mode).
There might be some cached test suite splits for git commits you have run in past for API token you used in queue mode because of the [flag `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true` for regular mode which is default](#knapsack_pro_fixed_test_suite_split-test-suite-split-based-on-seed).

* If you are not using one of the [supported CI providers](#supported-ci-providers) then please note that the knapsack_pro gem doesn't have a CI build ID in order to generate a queue for each particular CI build. This may result in two different CI builds taking tests from the same queue when CI builds are running at the same time against the same git commit.

  To avoid this you should specify a unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` environment variable for each CI build. This mean that each CI node that is part of particular CI build should have the same value for `KNAPSACK_PRO_CI_NODE_BUILD_ID`.

* Note that in the Queue Mode by default you cannot retry the failed CI node with exactly the same subset of tests that were run on the CI node in the first place. It's possible in regular mode ([read more](#knapsack_pro_fixed_test_suite_split-test-suite-split-based-on-seed)). If you want to have similar behavior in Queue Mode you need to explicitly [enable it](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node).

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

  * To [reproduce tests executed on CI node](https://knapsackpro.com/faq/question/how-to-run-tests-for-particular-ci-node-in-your-development-environment#for-knapsack_pro-queue-mode) in development environment please see FAQ.

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

Read more about [this feature](https://knapsackpro.com/faq/question/how-to-split-slow-rspec-test-files-by-test-examples-by-individual-it) and [common problems here](https://knapsackpro.com/faq/question/how-to-split-slow-rspec-test-files-by-test-examples-by-individual-it#common-problems).

> ❗ __RSpec requirement:__ You need `RSpec >= 3.3.0` in order to use this feature.

In order to split RSpec slow test files by test examples across parallel CI nodes you need to set environment variable:

```
KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=true
```

Thanks to that your CI build speed can be faster. We recommend using this feature with [Queue Mode](https://youtu.be/hUEB1XDKEFY) to ensure parallel CI nodes finish work at a similar time which gives you the shortest CI build time.

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

Read below required configuration step if you use Queue Mode and you set [`KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true`](#knapsack_pro_fixed_queue_split-remember-queue-split-on-retry-ci-node) or you use Regular Mode which has by default [`KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true`](#knapsack_pro_fixed_test_suite_split-test-suite-split-based-on-seed).

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

The knapsack_pro gem collects information about your test file names, branch names, and execution times. The data are stored on the KnapsackPro.com server.
If your test file names or branch names are considered sensitive data, then you can encrypt the data before sending it to the KnapsackPro.com API.

Encryption is disabled by default because the knapsack_pro gem uses your test file names to prepare a better test suite split when the execution time data are not collected on the KnapsackPro.com server yet.
When you enable the encryption, then your first test suite split may not be optimal.

Each test file name is generated with the `Digest::SHA2.hexdigest` method and 64 chars salt.

Before you enable encryption, please ensure you are using a fresh API token. Do not use the same API token for the encrypted and non-encrypted test suite. You can generate an API token for your test suite in the [user dashboard](https://knapsackpro.com/dashboard).

The next step is to generate a salt to encrypt test files or branch names with it.

```bash
bundle exec rake knapsack_pro:salt
```

Add the salt to your CI server as the `KNAPSACK_PRO_SALT` environment variable.

#### How to enable test file names encryption?

You need to add the `KNAPSACK_PRO_TEST_FILES_ENCRYPTED=true` environment variable to your CI server.

#### How to debug test file names?

If you need to check what is the hash value for a particular test file you can check that with the rake task:

```bash
KNAPSACK_PRO_SALT=xxx bundle exec rake "knapsack_pro:encrypted_test_file_names[rspec]"
```

You can pass the name of a test runner like `rspec`, `minitest`, `test_unit`, `cucumber`, `spinach` as an argument to the rake task.

#### How to enable branch names encryption?

You need to add the `KNAPSACK_PRO_BRANCH_ENCRYPTED=true` environment variable to your CI server.

Note a few branch names won't be encrypted because we use them as fallback branches on the Knapsack Pro API side to determine time execution for test files during split for newly created branches.

* develop
* development
* dev
* master
* staging
* [see the full list of excluded branch names from encryption](https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/lib/knapsack_pro/crypto/branch_encryptor.rb#L4)

#### How to debug branch names?

If you need to check what is the hash for a particular branch, then use the rake task:

```bash
# show all local branches and respective hashes
$ KNAPSACK_PRO_SALT=xxx bundle exec rake knapsack_pro:encrypted_branch_names

# show the hash for a branch name passed as an argument to the rake task
$ KNAPSACK_PRO_SALT=xxx bundle exec rake "knapsack_pro:encrypted_branch_names[not-encrypted-branch-name]"
```

### Supported CI providers

#### Info for CircleCI users

If you are using circleci.com you can omit `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX`. Knapsack Pro will use `CIRCLE_NODE_TOTAL` and `CIRCLE_NODE_INDEX` provided by CircleCI.

Here is an example for test configuration in your `.circleci/config.yml` file.

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

If you use knapsack_pro Queue Mode with CircleCI you may want to [collect metadata](https://circleci.com/docs/2.0/collect-test-data/#metadata-collection-in-custom-test-steps) like junit xml report about your RSpec test suite.

Here you can read how to configure [junit formatter](https://knapsackpro.com/faq/question/how-to-use-junit-formatter#how-to-use-junit-formatter-with-knapsack_pro-queue-mode). Step for CircleCI is to copy the xml report to `$CIRCLE_TEST_REPORTS` directory. Below is full config for your `spec_helper.rb`:

```ruby
# spec_helper.rb or rails_helper.rb

# TODO This must be the same path as value for rspec --out argument
# Note the path should not contain ~ char, for instance path ~/project/tmp/rspec.xml may not work. Please use full path instead.
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

You can find a complete CircleCI YML config example in [the article](https://docs.knapsackpro.com/2021/rspec-testing-parallel-jobs-with-circleci-and-junit-xml-report).

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
If you are going to relay on rspec to autobalance build when cucumber tests were not perfectly distributed you should be aware about [possible edge case if your rspec test suite is very short](https://knapsackpro.com/faq/question/why-my-tests-are-executed-twice-in-queue-mode-why-ci-node-runs-whole-test-suite-again).

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
        # [n] - where the n is a number of parallel jobs you want to run your tests on.
        # Use a higher number if you have slow tests to split them between more parallel jobs.
        # Remember to update the value of the `ci_node_index` below to (0..n-1).
        ci_node_total: [2]
        # Indexes for parallel jobs (starting from zero).
        # E.g. use [0, 1] for 2 parallel jobs, [0, 1, 2] for 3 parallel jobs, etc.
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

Update knapsack_pro gem version in:

* https://github.com/KnapsackPro/rails-app-with-knapsack_pro
* our private Knapsack Pro API repository

## Mentions

List of articles where people mentioned Knapsack Pro:

* [Treat your Build Pipeline as a Product](https://medium.com/mydr-engineering/treat-your-build-pipeline-as-a-product-61a1b24ae538).
  * Video - [Your Build Pipeline is a Product](https://www.youtube.com/watch?v=7e8Qk3H6xhg&t=21m14s)
