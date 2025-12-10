# Rails app with knapsack_pro gem

[![Circle CI](https://circleci.com/gh/KnapsackPro/rails-app-with-knapsack_pro.svg)](https://circleci.com/gh/KnapsackPro/rails-app-with-knapsack_pro)
[![Knapsack Pro Parallel CI builds for RSpec - Queue Mode - GitHub Actions](https://img.shields.io/badge/Knapsack%20Pro-Parallel%20/%20RSpec%20--%20Queue%20Mode%20--%20GitHub%20Actions-%230074ff)](https://knapsackpro.com/dashboard/organizations/54/projects/205/test_suites/815/builds)

This is example Ruby on Rails app with knapsack_pro gem. Knapsack Pro splits tests across CI nodes and makes sure that tests will run comparable time on each node.

__You can read more about [knapsack_pro gem here](https://github.com/KnapsackPro/knapsack_pro-ruby). You will find there info how to set up your test suite and how to do it on your favorite CI server.__


## How to load knapsack_pro rake tasks

See [Rakefile](Rakefile).


## Parallel rspec test suite with knapsack_pro

### How to set up knapsack_pro

See [spec/spec_helper.rb](spec/spec_helper.rb)

You can use below command on CI to run tests:

    # Run this on first CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:rspec

    # Run this on second CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:rspec

See [.circleci/config.yml](.circleci/config.yml) to see how we set up CircleCI.


## Parallel cucumber test suite with knapsack_pro

### How to set up knapsack_pro

See [features/support/knapsack_pro.rb](features/support/knapsack_pro.rb)

You can use below command on CI to run tests:

    # Run this on first CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:cucumber

    # Run this on second CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:cucumber

See [.circleci/config.yml](.circleci/config.yml) to see how we set up CircleCI.


## Parallel minitest test suite with knapsack_pro

### How to set up knapsack_pro

See [test/test_helper.rb](test/test_helper.rb)

You can use below command on CI to run tests:

    # Run this on first CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:minitest

    # Run this on second CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:minitest

See [.circleci/config.yml](.circleci/config.yml) to see how we set up CircleCI.

## Parallel test-unit test suite with knapsack_pro

### How to set up knapsack_pro

See [test-unit/test_helper.rb](test-unit/test_helper.rb)

You can use below command on CI to run tests:

    # Run this on first CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=0 bundle exec rake knapsack_pro:test_unit

    # Run this on second CI server
    $ KNAPSACK_PRO_CI_NODE_TOTAL=2 KNAPSACK_PRO_CI_NODE_INDEX=1 bundle exec rake knapsack_pro:test_unit

See [.circleci/config.yml](.circleci/config.yml) to see how we set up CircleCI.



# Development of this project

Ensure you created databases:

```
$ rake db:create db:migrate
$ TEST_ENV_NUMBER=1 rake db:create db:migrate
$ TEST_ENV_NUMBER=2 rake db:create db:migrate
```

In `bin` directory are files:

* `bin/knapsack_pro_rspec`
* `bin/knapsack_pro_minitest`
* `bin/knapsack_pro_test_unit`
* `bin/knapsack_pro_cucumber`

They exist for test reason when you want to run this project on local machine. In that case the `KNAPSACK_PRO_ENDPOINT` is pointed to staging which is reserved only for Knapsack Pro developers.

## RSpec dry run

```
$ mkdir -p tmp/knapsack_pro/rspec

$ bundle exec rspec --dry-run --format json --out tmp/knapsack_pro/rspec/dry_run.json spec
```
