# frozen_string_literal: true

require "thor"

module KnapsackPro
  class Commands < Thor
    map "queue:rspec" => :queue_rspec
    map "queue:cucumber" => :queue_cucumber
    map "queue:minitest" => :queue_minitest

    def self.exit_on_failure?
      true
    end

    desc "rspec ['arguments']", "Parallelize RSpec with Knapsack Pro in Regular Mode"
    def rspec(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::RSpecRunner.run(arguments)
    end

    desc "queue:rspec ['arguments']", "Parallelize RSpec with Knapsack Pro in Queue Mode"
    def queue_rspec(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::Queue::RSpecRunner.run(arguments)
    end

    desc "cucumber ['arguments']", "Parallelize Cucumber with Knapsack Pro in Regular Mode"
    def cucumber(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::CucumberRunner.run(arguments)
    end

    desc "queue:cucumber ['arguments']", "Parallelize Cucumber with Knapsack Pro in Queue Mode"
    def queue_cucumber(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::Queue::CucumberRunner.run(arguments)
    end

    desc "minitest ['arguments']", "Parallelize Minitest with Knapsack Pro in Regular Mode"
    def minitest(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::MinitestRunner.run(arguments)
    end

    desc "queue:minitest ['arguments']", "Parallelize Minitest with Knapsack Pro in Queue Mode"
    def queue_minitest(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::Queue::MinitestRunner.run(arguments)
    end

    desc "test_unit ['arguments']", "Parallelize TestUnit with Knapsack Pro in Regular Mode"
    def test_unit(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::TestUnitRunner.run(arguments)
    end

    desc "spinach ['arguments']", "Parallelize Spinach with Knapsack Pro in Regular Mode"
    def spinach(arguments = "")
      require "knapsack_pro"
      KnapsackPro::Runners::SpinachRunner.run(arguments)
    end

    desc "retry [-b] [-- test_runner_args]", "Retry RSpec the tests that failed on the previous Knapsack Pro run on BRANCH."
    long_desc <<~DESC
      \x5knapsack_pro retry
      \x5knapsack_pro retry --branch feature -- --format progress
    DESC
    option :branch, type: :string, aliases: :b, desc: "Default: current branch."
    def retry(*runner_args)
      require_relative "./commands/retry_failed_tests"
      KnapsackPro::RetryFailedTests.new(options[:branch]).call(runner_args)
    end
  end
end
