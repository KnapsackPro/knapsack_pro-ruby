# knapsack_pro ruby gem

[![Circle CI](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby.svg)](https://circleci.com/gh/KnapsackPro/knapsack_pro-ruby)
[![Gem Version](https://badge.fury.io/rb/knapsack_pro.svg)](https://rubygems.org/gems/knapsack_pro)
[![Code Climate](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby/badges/gpa.svg)](https://codeclimate.com/github/KnapsackPro/knapsack_pro-ruby)
[![Test Coverage](https://codeclimate.com/github/KnapsackPro/knapsack-pro-ruby/badges/coverage.svg)](https://codeclimate.com/github/KnapsackPro/knapsack-pro-ruby/coverage)

Knapsack Pro gem splits tests across CI nodes and makes sure that tests will run comparable time on each node. It uses [KnapsackPro.com API](http://docs.knapsackpro.com). Original idea came from [knapsack](https://github.com/ArturT/knapsack) gem.

The knapsack_pro gem supports:

* [RSpec](http://rspec.info)
* [Cucumber](https://cucumber.io)
* [Minitest](http://docs.seattlerb.org/minitest/)
* [Spinach](https://github.com/codegram/spinach)
* [Turnip](https://github.com/jnicklas/turnip)

__Would you like to try knapsack_pro gem?__ You can [get API token here](http://knapsackpro.com?utm_source=github&utm_medium=readme&utm_campaign=knapsack_pro-ruby_gem&utm_content=get_api_token).

## Is knapsack_pro gem free?

* If your __project is open source__ then you can use Knapsack Pro for free. Just add a link back to the page http://knapsackpro.com and please let me know via email (arturtrzop@gmail.com). I will mark your account on KnapsackPro.com as open source.

* If your __project is commercial__ then I'd like to get feedback from you and work closely together to validate if the solution I'm building provide a value for the users. Switching to paid plan is a good way to validate that and a way to get support from happy users. Currently, there is no hard limit when the free trial is ending. I'm more interested in getting feedback from users in order to improve the tool. As I saw in the past people want to support the project and are asking for paid plan. Maybe you will be the next one who will join and support the project. Thanks!

# How knapsack_pro works?

## Basics

Basically it will track your branches, commits and for how many CI nodes you are running tests.
Collected data about test time execution will be send to API where test suite split is done.
Next time when you will run tests you will get proper test files for each CI node in order to achieve comparable time execution on each CI node.

## Details

For instance when you will run tests with `rake knapsack_pro:rspec` then:

* information about all your existing test files are sent to API http://docs.knapsackpro.com/api/v1/#build_distributions_subset_post
* API returns which files should be executed on particular CI node (example KNAPSACK_PRO_CI_NODE_INDEX=0)
* when API server has info about previous tests runs then it will use it to return more accurate test split results, in other case API returns simple split based on directory names
* knapsack_pro will run test files which got from API
* after tests finished knapsack_pro will send information about time execution of each file to API http://docs.knapsackpro.com/api/v1/#build_subsets_post so data can be used for future test runs

The knapsack_pro has also [queue mode](#queue-mode) to get most optimal test suite split.

# Requirements

* >= Ruby 2.0.0

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
    - [Step for Spinach](#step-for-spinach)
    - [Custom configuration](#custom-configuration)
  - [Setup your CI server (How to set up 2 of 3)](#setup-your-ci-server-how-to-set-up-2-of-3)
    - [Set API key token](#set-api-key-token)
    - [Set knapsack_pro command to execute tests](#set-knapsack_pro-command-to-execute-tests)
  - [Repository adapter (How to set up 3 of 3)](#repository-adapter-how-to-set-up-3-of-3)
    - [When you NOT set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER` (default)](#when-you-not-set-global-variable-knapsack_pro_repository_adapter-default)
    - [When you set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER=git` (required when CI provider is not supported)](#when-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported)
- [Queue Mode](#queue-mode)
  - [How queue mode works?](#how-queue-mode-works)
  - [How to use queue mode?](#how-to-use-queue-mode)
  - [Additional info about queue mode](#additional-info-about-queue-mode)
  - [Supported test runners in queue mode](#supported-test-runners-in-queue-mode)
- [Extra configuration for CI server](#extra-configuration-for-ci-server)
  - [Info about ENV variables](#info-about-env-variables)
    - [KNAPSACK_PRO_FIXED_TEST_SUITE_SPLITE (test suite split based on seed)](#knapsack_pro_fixed_test_suite_splite-test-suite-split-based-on-seed)
    - [Environment variables for debugging gem](#environment-variables-for-debugging-gem)
  - [Passing arguments to rake task](#passing-arguments-to-rake-task)
    - [Passing arguments to rspec](#passing-arguments-to-rspec)
    - [Passing arguments to cucumber](#passing-arguments-to-cucumber)
    - [Passing arguments to minitest](#passing-arguments-to-minitest)
    - [Passing arguments to spinach](#passing-arguments-to-spinach)
  - [Knapsack Pro binary](#knapsack-pro-binary)
  - [Test file names encryption](#test-file-names-encryption)
    - [How to enable test file names encryption?](#how-to-enable-test-file-names-encryption)
    - [How to debug test file names?](#how-to-debug-test-file-names)
  - [Supported CI providers](#supported-ci-providers)
    - [Info for CircleCI users](#info-for-circleci-users)
    - [Info for Travis users](#info-for-travis-users)
    - [Info for semaphoreapp.com users](#info-for-semaphoreappcom-users)
    - [Info for buildkite.com users](#info-for-buildkitecom-users)
    - [Info for snap-ci.com users](#info-for-snap-cicom-users)
- [FAQ](#faq)
  - [How to run tests for particular CI node in your development environment](#how-to-run-tests-for-particular-ci-node-in-your-development-environment)
  - [What happens when Knapsack Pro API is not available/not reachable temporarily?](#what-happens-when-knapsack-pro-api-is-not-availablenot-reachable-temporarily)
  - [How can I change log level?](#how-can-i-change-log-level)
  - [How to split tests based on test level instead of test file level?](#how-to-split-tests-based-on-test-level-instead-of-test-file-level)
    - [A. Create multiple small test files](#a-create-multiple-small-test-files)
    - [B. Use tags to mark set of tests in particular test file](#b-use-tags-to-mark-set-of-tests-in-particular-test-file)
- [Gem tests](#gem-tests)
  - [Spec](#spec)
- [Contributing](#contributing)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

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

    $ bundle install


Add this lines at the bottom of `Rakefile` if your project has it:

```ruby
KnapsackPro.load_tasks if defined?(KnapsackPro)
```

Run installer to get started. It will ask you a few questions and generate instruction steps for your project.

    $ bundle exec rake knapsack_pro:install

You can read next section only if you want to better understand optional gem configuration and features.

## How to set up

If you are using [VCR gem](https://github.com/vcr/vcr) then add Knapsack Pro API subdomain to [ignore hosts](https://www.relishapp.com/vcr/vcr/v/2-9-3/docs/configuration/ignore-request):

```ruby
# spec/spec_helper.rb or wherever is your VCR configuration

VCR.configure do |config|
  config.ignore_hosts 'localhost', '127.0.0.1', '0.0.0.0', 'api.knapsackpro.com'
end

WebMock.disable_net_connect!(:allow => 'api.knapsackpro.com') if defined?(WebMock)
```

### Usage (How to set up 1 of 3)

__Tip:__ You can find here example of rails app with already configured knapsack_pro.

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

#### Step for Spinach

Create file `features/support/knapsack_pro.rb` and add there:

```ruby
require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

KnapsackPro::Adapters::SpinachAdapter.bind
```

#### Custom configuration

You can change default Knapsack Pro configuration for RSpec, Cucumber, Minitest or Spinach tests. Here are examples what you can do. Put below configuration instead of `CUSTOM_CONFIG_GOES_HERE`.

```ruby
# you can use your own logger
require 'logger'
KnapsackPro.logger = Logger.new(STDOUT)
KnapsackPro.logger.level = Logger::INFO
```

### Setup your CI server (How to set up 2 of 3)

#### Set API key token

Set one or a few tokens depend on how many test suites you run on CI server.

* `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` - as value set token for rspec test suite. Token can be generated when you sign in to [knapsackpro.com](http://www.knapsackpro.com).
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER` - token for cucumber test suite.
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST` - token for minitest test suite.
* `KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH` - token for minitest test suite.

__Tip:__ In case you have for instance multiple rspec test suites then prepend each of knapsack_pro command which executes tests with `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` variable.

#### Set knapsack_pro command to execute tests

On your CI server run this command for the first CI node. Update `KNAPSACK_PRO_CI_NODE_INDEX` for the next one.

    # Step for RSpec
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec

    # Step for Cucumber
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

    # Step for Minitest
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest

    # Step for Spinach
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach

You can add `KNAPSACK_PRO_TEST_FILE_PATTERN` if your tests are not in default directory. For instance:

    # Step for RSpec
    $ KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_specs/**{,/*/**}/*_spec.rb" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec

    # Step for Cucumber
    $ KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_features/**{,/*/**}/*.feature" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

    # Step for Minitest
    $ KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_tests/**{,/*/**}/*_test.rb" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest

    # Step for Spinach
    $ KNAPSACK_PRO_TEST_FILE_PATTERN="directory_with_features/**{,/*/**}/*.feature" KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:spinach

__Tip:__ If you use one of supported CI providers then instead of above steps you should [take a look on this](#supported-ci-providers).

__Tip 2:__ If you use one of unsupported CI providers ([here is list of supported CI providers](#supported-ci-providers)) then you should [set KNAPSACK_PRO_REPOSITORY_ADAPTER=git](#when-you-set-global-variable-knapsack_pro_repository_adaptergit-required-when-ci-provider-is-not-supported).

### Repository adapter (How to set up 3 of 3)

#### When you NOT set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER` (default)

By default `KNAPSACK_PRO_REPOSITORY_ADAPTER` variable has no value so knapsack_pro will try to get info about branch name and commit hash from [supported CI](#supported-ci-providers) (CI providers have branch, commit, project directory stored as environment variables). In case when you use other CI provider like Jenkins then please set below variables on your own.

`KNAPSACK_PRO_BRANCH` - It's branch name. You run tests on this branch.

`KNAPSACK_PRO_COMMIT_HASH` - Commit hash. You run tests for this commit.

You can also use git as repository adapter to determine branch and commit hash, please see below section.

#### When you set global variable `KNAPSACK_PRO_REPOSITORY_ADAPTER=git` (required when CI provider is not supported)

`KNAPSACK_PRO_REPOSITORY_ADAPTER` - When it has value `git` then your local version of git on CI server will be used to get info about branch name and commit hash. You need to set also `KNAPSACK_PRO_PROJECT_DIR` with project directory path.

`KNAPSACK_PRO_PROJECT_DIR` - Path to the project on CI node for instance `/home/ubuntu/my-app-repository`. It should be main directory of your repository.

## Queue Mode

knapsack_pro has built in queue mode designed to solve problem with optimal test suite split in case of random time execution of test files caused by
CI node overload and a random decrease of performance that may affect how long the test files are executed.
The problem with random time execution of test files may be caused by many things like external requests done in tests.

### How queue mode works?

On the Knapsack Pro API side, there is test files queue generated for your CI build. Each of CI node dynamically asks the Knapsack Pro API for test files
that should be executed. Thanks to that each CI node will finish tests at the same time.

### How to use queue mode?

Please use this command to run queue mode:

    bundle exec rake knapsack_pro:queue:rspec

If above command fails then you may need to explicitly pass an argument to require `rails_helper` file or `spec_helper` in case you are not doing this in some of your test files:

    bundle exec rake "knapsack_pro:queue:rspec[--require rails_helper]"

Note if you will run queue mode command for the first time it might be slower.
The second build should have better optimal test suite split.

### Additional info about queue mode

If you are not using one of supported CI providers then please note that knapsack_pro gem doesn't know what is CI build ID in order to generated queue for particular CI build. This may result in two different CI builds taking tests from the same queue when CI builds are running at the same time against the same git commit.
To avoid this you can specify unique `KNAPSACK_PRO_CI_NODE_BUILD_ID` environment variable for each CI build. This mean that each CI node that is part of particular CI build should have the same value for `KNAPSACK_PRO_CI_NODE_BUILD_ID`.

### Supported test runners in queue mode

At this moment the queue mode works for:

* RSpec

## Extra configuration for CI server

### Info about ENV variables

By default knapsack_pro gem [supports a few CI providers](#supported-ci-providers) so you don't need to set some environment variables.
In case when you use other CI provider for instance [Jenkins](https://jenkins-ci.org) etc then you need to provide configuration via below environment variables.

`KNAPSACK_PRO_CI_NODE_TOTAL` - total number CI nodes you have.

`KNAPSACK_PRO_CI_NODE_INDEX` - index of current CI node starts from 0. Second CI node should have `KNAPSACK_PRO_CI_NODE_INDEX=1`.

#### KNAPSACK_PRO_FIXED_TEST_SUITE_SPLITE (test suite split based on seed)

* `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true` (default)

    It means when you run test suite again for the same commit hash and total number of nodes and for the same branch
    then you will get exactly the same test suite split.

    Thanks to that when tests on one of your node failed you can retry the node with exactly the same subset of tests that were run on the node in the first place.

    There is one edge case. When you run tests for the first time and there is no data collected about time execution of your tests then
    we need to collect data to prepare the first test suite split. The second run of your tests will have fixed test suite split.

    To compare if all your CI nodes are running based on the same test suite split seed you can check the value for seed in knapsack logging message
    before your test starts. The message looks like:

        [knapsack_pro] Test suite split seed: 8a606431-02a1-4766-9878-0ea42a07ad21

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

`KNAPSACK_PRO_ENDPOINT` - Default value is `http://api.knapsackpro.com` which is endpoint for [Knapsack Pro API](http://docs.knapsackpro.com).

`KNAPSACK_PRO_MODE` - Default value is `production`. When mode is `development` then endpoint is `http://api.knapsackpro.dev:3000`. When mode is `test` then endpoint is `http://api-staging.knapsackpro.com`.

### Passing arguments to rake task

#### Passing arguments to rspec

Knapsack Pro allows you to pass arguments through to rspec. For example if you want to run only specs that have the tag `focus`. If you do this with rspec directly it would look like:

    $ bundle exec rake rspec --tag focus

To do this with Knapsack Pro you simply add your rspec arguments as parameters to the knapsack_pro rake task.

    $ bundle exec rake "knapsack_pro:rspec[--tag focus]"

#### Passing arguments to cucumber

Add arguments to knapsack_pro cucumber task like this:

    $ bundle exec rake "knapsack_pro:cucumber[--name feature]"

#### Passing arguments to minitest

Add arguments to knapsack_pro minitest task like this:

    $ bundle exec rake "knapsack_pro:minitest[--arg_name value]"

For instance to run verbose tests:

    $ bundle exec rake "knapsack_pro:minitest[--verbose]"

#### Passing arguments to spinach

Add arguments to knapsack_pro spinach task like this:

    $ bundle exec rake "knapsack_pro:spinach[--arg_name value]"

### Knapsack Pro binary

You can install knapsack_pro globally and use binary. For instance:

    $ knapsack_pro rspec "--tag custom_tag_name --profile"
    $ knapsack_pro cucumber "--name feature"
    $ knapsack_pro minitest "--verbose --pride"
    $ knapsack_pro spinach "--arg_name value"

This is optional way of using knapsack_pro when you don't want to add it to `Gemfile`.

### Test file names encryption

knapsack_pro gem collects information about you test file names and time execution. Those data are stored on KnapsackPro.com server.
If your test file names are sensitive data then you can encrypt the names before sending them to KnapsackPro.com API.

By default, encryption is disabled because knapsack_pro can use your test files names to prepare better test suite split when the time execution data are not yet collected on KnapsackPro.com server.
When you will enable test file names encryption then your first test suite split may be less optimal than it could be.

Each test file name is generated with `Digest::SHA2.hexdigest` method and 64 chars salt.

Before you enable test file encryption please ensure you are using fresh API key. You should not use the same API key for encrypted and non encrypted test suite.
You can generate API key for your test suite in [your dashboard](https://knapsackpro.com).

#### How to enable test file names encryption?

First you need to add environment variable `KNAPSACK_PRO_TEST_FILES_ENCRYPTED=true` to your CI server.

Next step is to generate salt which will be used to encrypt test file names.

    $ bundle exec rake knapsack_pro:salt

Add to your CI server generated environment variable `KNAPSACK_PRO_SALT`.

#### How to debug test file names?

If you need to check what is the encryption hash for particular test file your can check that with the rake task:

    $ KNAPSACK_PRO_SALT=xxx bundle exec rake knapsack_pro:encrypted_test_file_names[rspec]

You can pass the name of test runner like rspec, minitest, cucumber, spinach as argument to rake task.

### Supported CI providers

#### Info for CircleCI users

If you are using circleci.com you can omit `KNAPSACK_PRO_CI_NODE_TOTAL` and `KNAPSACK_PRO_CI_NODE_INDEX`. Knapsack Pro will use `CIRCLE_NODE_TOTAL` and `CIRCLE_NODE_INDEX` provided by CircleCI.

Here is an example for test configuration in your `circleci.yml` file.

```yaml
machine:
  environment:
    # Tokens should be set in CircleCI settings to avoid expose tokens in build logs
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC: rspec-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER: cucumber-token
    # KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST: minitest-token
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

    # Step for Spinach
    - bundle exec rake knapsack_pro:spinach:
        parallel: true # Caution: there are 8 spaces indentation!
```

Please remember to add additional containers for your project in CircleCI settings.

#### Info for Travis users

You can parallelize your builds across virtual machines with [travis matrix feature](http://docs.travis-ci.com/user/speeding-up-the-build/#Parallelizing-your-builds-across-virtual-machines). Edit `.travis.yml`

```yaml
script:
  # Step for RSpec
  - "bundle exec rake knapsack_pro:rspec"

  # Step for Cucumber
  - "bundle exec rake knapsack_pro:cucumber"

  # Step for Minitest
  - "bundle exec rake knapsack_pro:minitest"

  # Step for Spinach
  - "bundle exec rake knapsack_pro:spinach"

env:
  global:
    # tokens should be set in travis settings in web interface to avoid expose tokens in build logs
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token
    - KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token

    - KNAPSACK_PRO_CI_NODE_TOTAL=2
  matrix:
    - KNAPSACK_PRO_CI_NODE_INDEX=0
    - KNAPSACK_PRO_CI_NODE_INDEX=1
```

Such configuration will generate matrix with 2 following ENV rows:

    KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token
    KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=rspec-token KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER=cucumber-token KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST=minitest-token KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH=spinach-token

More info about global and matrix ENV configuration in [travis docs](http://docs.travis-ci.com/user/build-configuration/#Environment-variables).

#### Info for semaphoreapp.com users

Knapsack Pro supports semaphoreapp ENVs `SEMAPHORE_THREAD_COUNT` and `SEMAPHORE_CURRENT_THREAD`. The only thing you need to do is set up knapsack_pro rspec/cucumber/minitest command for as many threads as you need. Here is an example:

    # Thread 1
    ## Step for RSpec
    bundle exec rake knapsack_pro:rspec
    ## Step for Cucumber
    bundle exec rake knapsack_pro:cucumber
    ## Step for Minitest
    bundle exec rake knapsack_pro:minitest
    ## Step for Spinach
    bundle exec rake knapsack_pro:spinach

    # Thread 2
    ## Step for RSpec
    bundle exec rake knapsack_pro:rspec
    ## Step for Cucumber
    bundle exec rake knapsack_pro:cucumber
    ## Step for Minitest
    bundle exec rake knapsack_pro:minitest
    ## Step for Spinach
    bundle exec rake knapsack_pro:spinach

Tests will be split across threads.

Please remember to set up token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for buildkite.com users

Knapsack Pro supports buildkite ENVs `BUILDKITE_PARALLEL_JOB_COUNT` and `BUILDKITE_PARALLEL_JOB`. The only thing you need to do is to configure the parallelism parameter in your build step and run the appropiate command in your build

    # Step for RSpec
    bundle exec rake knapsack_pro:rspec

    # Step for Cucumber
    bundle exec rake knapsack_pro:cucumber

    # Step for Minitest
    bundle exec rake knapsack_pro:minitest

    # Step for Spinach
    bundle exec rake knapsack_pro:spinach

Please remember to set up token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

#### Info for snap-ci.com users

Knapsack Pro supports snap-ci.com ENVs `SNAP_WORKER_TOTAL` and `SNAP_WORKER_INDEX`. The only thing you need to do is to configure number of workers for your project in configuration settings in order to enable parallelism. Next thing is to set below commands to be executed in your stage:

    # Step for RSpec
    bundle exec rake knapsack_pro:rspec

    # Step for Cucumber
    bundle exec rake knapsack_pro:cucumber

    # Step for Minitest
    bundle exec rake knapsack_pro:minitest

    # Step for Spinach
    bundle exec rake knapsack_pro:spinach

Please remember to set up token like `KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC` as global environment.

## FAQ

### How to run tests for particular CI node in your development environment

In your development environment you can debug tests that were run on the particular CI node.
For instance to run subset of tests for the first CI node with specified seed you can do.

    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=token \
    KNAPSACK_PRO_REPOSITORY_ADAPTER=git \
    KNAPSACK_PRO_PROJECT_DIR=~/projects/rails-app \
    KNAPSACK_PRO_CI_NODE_TOTAL=2 \
    KNAPSACK_PRO_CI_NODE_INDEX=0 \
    bundle exec rake "knapsack_pro:rspec[--seed 123]"

Above example is for RSpec. You can use respectively rake task name and token environment variable when you want to run tests for minitest, cucumber or spinach.

### What happens when Knapsack Pro API is not available/not reachable temporarily?

knapsack_pro gem has fallback behaviour and it will split test files across CI nodes based on popular test directory names.

### How can I change log level?

You can change log level by specifying the `KNAPSACK_PRO_LOG_LEVEL` environment variable.

    KNAPSACK_PRO_LOG_LEVEL=warn bundle exec rake knapsack_pro:rspec

Available values are `debug`, `info`, and `warn`. The default log level is `info`.

### How to split tests based on test level instead of test file level?

If you want to split one big test file (test file with long time execution) across multiple CI nodes then you can:

#### A. Create multiple small test files

Create multiple small test files instead of one long running test file with many test cases.
A lot of small test files will give you better test suite split results.

#### B. Use tags to mark set of tests in particular test file

Another way is to use tags to mark subset of tests in particular test file and then split tests based on tags.

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

You need to create multiple API tokens for different tags. In this example we need 3 different API tokens.

You need to run below commands for each CI node.

    # run only tests with tagA
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tagA bundle exec rake "knapsack_pro:rspec[--tag tagA]"

    # run only tests with tagB
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tagB bundle exec rake "knapsack_pro:rspec[--tag tagB]"

    # run other tests without tag A & B
    KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC=api_key_for_tests_without_tags_A_and_B bundle exec rake "knapsack_pro:rspec[--tag ~tagA --tag ~tagB]"

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
