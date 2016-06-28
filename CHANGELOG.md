### unreleased

* TODO

### 0.10.0

Add new environment variable KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT. The default value is true.

It means when you run test suite again for the same commit hash and total number of nodes and for the same branch
then you will get exactly the same test suite split.
This is the new default behavior for the knapsack_pro gem. Thanks to that when tests on one of your node failed
you can retry the node with exactly the same subset of tests that were run on the node in the first place.

There is one edge case. When you run tests for the first time and there is no data collected about time execution of your tests then
we need to collect data first to prepare first test suite split. The second run of your tests will have fixed test suite split.
To compare if all your CI nodes are running based on the same test suite split seed you can check the value for seed in knapsack logging message
before your test starts. The message looks like:

    [knapsack_pro] Test suite split seed: 8a606431-02a1-4766-9878-0ea42a07ad21

* Show test suite split seed in logger based on build_distribution_id from Knapsack Pro API.
* Send fixed_test_suite_split param to build distribution Knapsack Pro API endpoint.

Related issues:

https://github.com/KnapsackPro/knapsack_pro-ruby/issues/15
https://github.com/KnapsackPro/knapsack_pro-ruby/issues/12

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.9.0...v0.10.0

### 0.9.0

* Add https support for Knapsack Pro API endpoint

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/14

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.8.0...v0.9.0

### 0.8.0

* Add Spinach support

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/11

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.7.2...v0.8.0

### 0.7.2

* Preserve cucumber latest error message with exit code to fix problem with false positive cucumber failed tests

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/10

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.7.1...v0.7.2

### 0.7.1

* Don't fail when there are no tests to run on a node

    https://github.com/KnapsackPro/knapsack_pro-ruby/issues/7
    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/9

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.7.0...v0.7.1

### 0.7.0

* Add support for older cucumber versions than 1.3

    https://github.com/KnapsackPro/knapsack_pro-ruby/issues/5

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.6.1...v0.7.0

### 0.6.1

* Changed rake task in minitest_runner.rb to have no warnings output

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/4

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.6.0...v0.6.1

### 0.6.0

* Add support for Cucumber 2

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.5.0...v0.6.0

### 0.5.0

* Remove active support dependency so knapsack_pro gem can be used with rails 2.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.4.0...v0.5.0

### 0.4.0

* Add support for snap-ci.com

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.3.0...v0.4.0

### 0.3.0

* Remove keyword arguments in order to add support for old ruby versions.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.2.1...v0.3.0

### 0.2.1

* TestFileFinder should find unique files without duplicates when using test file pattern supporting symlinks
* Update test file pattern to support symlinks in specs and readme examples
* Backwards compatibility with knapsack gem old rspec adapter name

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.2.0...v0.2.1

### 0.2.0

* Change file path patterns to support 1-level symlinks by default

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/2

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.1.2...v0.2.0

### 0.1.2

* Fix Travis CI environment variables support

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/1

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.1.1...v0.1.2

### 0.1.1

* Make knapsack_pro backwards compatible with earlier version of minitest

    Related PR from knapsack gem repository:
    https://github.com/ArturT/knapsack/pull/26

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.1.0...v0.1.1

### 0.1.0

First working release on rubygems.org.

### 0.0.1

Init repository.
