module KnapsackPro
  module Runners
    class CucumberRunner < BaseRunner
      def self.run(args)
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_cucumber

        runner = new(KnapsackPro::Adapters::CucumberAdapter)

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true KNAPSACK_PRO_TEST_SUITE_TOKEN=#{ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN']} bundle exec cucumber #{args} -- #{runner.stringify_test_file_paths}]

        Kernel.system(cmd)
        Kernel.exit($?.exitstatus) unless $?.exitstatus.zero?
      end
    end
  end
end
