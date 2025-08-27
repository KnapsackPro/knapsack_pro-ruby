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

    desc "retry [-b] [-- test_runner_args]", "Retry the tests that failed on the previous Knapsack Pro run on BRANCH."
    long_desc <<~DESC
      \x5knapsack_pro retry
      \x5knapsack_pro retry --branch feature -- --format progress
    DESC
    option :branch, type: :string, aliases: :b, desc: "Default: current branch."
    def retry(*runner_args)
      test_examples = fetch_test_examples
      return (puts "Nothing to run") if test_examples.size.zero?

      puts "Retrying #{test_examples.size} test examples..."
      exec Gem.bin_path("rspec-core", "rspec"), *(runner_args + test_examples)
    end

    private

    def fetch_test_examples
      require "json"
      require "net/http"
      require "knapsack_pro/config/env"

      branch = options[:branch] || `git branch --show-current`.chomp
      puts "Branch: #{branch}"

      headers = {
        'Accept' => 'application/json',
        'KNAPSACK-PRO-TEST-SUITE-TOKEN' => ENV.fetch("KNAPSACK_PRO_TEST_SUITE_TOKEN")
      }

      uri = URI.parse("#{KnapsackPro::Config::Env.endpoint}/v2/paths")
      uri.query = URI.encode_www_form(branch: branch)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = 5
      http.read_timeout = 5

      response = http.get(uri, headers)
      abort response.inspect if (300..).cover?(response.code.to_i)

      parsed = JSON.parse(response.body)
      abort parsed.inspect if parsed['errors']

      parsed.fetch('paths')
    end
  end
end

KnapsackPro::Commands.start(ARGV)
