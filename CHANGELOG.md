### unreleased

* TODO

### 0.44.0

* Add ability to set test_dir using an environment variable.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/45

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.43.0...v0.44.0

### 0.43.0

* Extract correct test directory from test file pattern that has multiple patterns.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/43

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.42.0...v0.43.0

### 0.42.0

* Clear RSpec examples without shared examples in similar way as in RSpec 3.6.0

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/42

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.41.0...v0.42.0

### 0.41.0

* Add after subset queue hook and example how to use JUnit formatter in Queue Mode.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/41

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.40.0...v0.41.0

### 0.40.0

* Replace rake task installer `knapsack_pro:install` with online installation guide. Remove `tty-prompt` gem dependency.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/39

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.39.0...v0.40.0

### 0.39.0

* Remove timecop gem from required dependencies list.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/38

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.38.0...v0.39.0

### 0.38.0

* Add support for Gitlab CI.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/36

* More info about Buildkite in installer.
* More info about CircleCI in installer.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.37.0...v0.38.0

### 0.37.0

* Add another explanation why test files could not be executed on CI node in Queue Mode.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/34

* Show better explanation what to do when there is missing test suite token environment variable.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/35

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.36.0...v0.37.0

### 0.36.0

* Show messages about not executed test files as warnings in logs.
* Handle case when start timer was not called (rspec-retry issue).

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/33

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.35.0...v0.36.0

### 0.35.0

* Add `RSpecQueueProfileFormatterExtension` to show profile summary only once at the very end of RSpec Queue Mode output.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.34.0...v0.35.0

### 0.34.0

* Fix command visible at the end of RSpec Queue Mode output to be able retry test files with spaces in name.
* Fix command visible at the end of RSpec Queue Mode output to be able retry test files without RSpecQueueSummaryFormatter which is dedicated only for Queue Mode.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.33.0...v0.34.0

### 0.33.0

* Add RSpec Queue Formatter to hide duplicated pending and failed tests in Queue Mode

  You can keep duplicated pending/failed summary with flag `KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS`. More can be found in read me.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/31

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.32.0...v0.33.0

### 0.32.0

* Add encryption for branch names

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/30

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.31.0...v0.32.0

### 0.31.0

* Add supported for log levels `fatal` and `error` by `KNAPSACK_PRO_LOG_LEVEL` environment variable.
* Allow `KNAPSACK_PRO_LOG_LEVEL` case insensitive.
* Move all messages related to requests to Knapsack Pro API in log `debug` level and keep `info` level only for important messages like how to retry tests in development or info why something works this way or the other (for instance why tests were not executed on the CI node).

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/29

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.30.0...v0.31.0

### 0.30.0

* Update license to MIT.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.29.0...v0.30.0

### 0.29.0

* Add info about Jenkins to installer.
* Extend info about final step in installer about verification if first test suite run was recorded correctly.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.28.1...v0.29.0

### 0.28.1

* Add support for test files in directory with spaces.

    https://github.com/KnapsackPro/knapsack_pro-ruby/issues/27

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.28.0...v0.28.1

### 0.28.0

* Show at the end of `knapsack_pro:queue:rspec` command the example how to run all tests executed for the CI node in the development environment.
* Show for each intermediate request to Knapsack Pro API queue how to run a subset of tests fetched from API.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.27.0...v0.28.0

### 0.27.0

* Save build subset to API even when no test files were executed on CI node. Add warnings to notify why the test files were not executed on CI node in particular mode: regular or queue mode.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.26.0...v0.27.0

### 0.26.0

* Add info how to allow FakeWeb to connect with Knapsack Pro API in install rake task.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.25.0...v0.26.0

### 0.25.0

* Queue mode retry (remember queue split on retry CI node).

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/22

* Fix bug in queue mode with recording test files time execution data. Previously the same test files time execution data where multiple times send to Knapsack Pro API.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/23

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.24.0...v0.25.0

### 0.24.0

* Send client name and version in headers for each request to Knapsack Pro API.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.23.0...v0.24.0

### 0.23.0

* Add info about Queue Mode to install rake task.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.22.0...v0.23.0

### 0.22.0

*  Add more info how to set up VCR and webmock to `knapsack_pro:install` rake task.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.21.0...v0.22.0

### 0.21.0

* Improve VCR config documentation so it's more clear that ignore_hosts takes arguments instead of array

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.20.0...v0.21.0

### 0.20.0

* Wait a few seconds before retrying failed request to API. With each retry wait a bit longer. Retry at most 5 times.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.19.0...v0.20.0

### 0.19.0

* Change timeout to 30s for requests to API.
* Retry failed request to API at most 3 times.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.18.0...v0.19.0

### 0.18.0

* Add support for knapsack_pro queue mode

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/20

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.17.0...v0.18.0

### 0.17.0

* Enable fallback mode for SocketError when failed to open TCP connection to http or https API endpoint.

### 0.16.0

* Add KNAPSACK_PRO_LOG_LEVEL option

    Related PR:
    https://github.com/ArturT/knapsack/pull/49

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.15.2...v0.16.0

### 0.15.2

* Cache API response test file paths to fix problem with double request to get test suite distribution for the node.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.15.1...v0.15.2

### 0.15.1

* Fix support for turnip >= 2.x

    Related PR:
    https://github.com/ArturT/knapsack/pull/47

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.15.0...v0.15.1

### 0.15.0

* Handle case when API returns no test files to execute on the node.

    https://github.com/KnapsackPro/knapsack_pro-ruby/pull/19

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.14.0...v0.15.0

### 0.14.0

* Use rake invoke for rspec and cucumber tasks.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.13.0...v0.14.0

### 0.13.0

* Add installer to get started with the knapsack_pro gem.

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.12.0...v0.13.0

### 0.12.0

* Add support for Minitest::SharedExamples

    Related PR:
    https://github.com/ArturT/knapsack/pull/46

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.11.0...v0.12.0

### 0.11.0

* Add test file names encryption

https://github.com/KnapsackPro/knapsack_pro-ruby/compare/v0.10.0...v0.11.0

### 0.10.0

* Add new environment variable `KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT`. The default value is true.

    It means when you run test suite again for the same commit hash and total number of nodes and for the same branch
    then you will get exactly the same test suite split.
    This is the new default behavior for the knapsack_pro gem. Thanks to that when tests on one of your node failed
    you can retry the node with exactly the same subset of tests that were run on the node in the first place.

    There is one edge case. When you run tests for the first time and there is no data collected about time execution of your tests then
    we need to collect data to prepare the first test suite split. The second run of your tests will have fixed test suite split.
    To compare if all your CI nodes are running based on the same test suite split seed you can check the value for seed in knapsack logging message
    before your test starts. The message looks like:

        [knapsack_pro] Test suite split seed: 8a606431-02a1-4766-9878-0ea42a07ad21

  * Show test suite split seed in logger based on `build_distribution_id` from Knapsack Pro API.
  * Send `fixed_test_suite_split` param to build distribution Knapsack Pro API endpoint.

  Related issues:

  * https://github.com/KnapsackPro/knapsack_pro-ruby/issues/15
  * https://github.com/KnapsackPro/knapsack_pro-ruby/issues/12

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
