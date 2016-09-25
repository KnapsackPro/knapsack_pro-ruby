module KnapsackPro
  module Runners
    class CucumberRunner < BaseRunner
      def self.run(args)
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_cucumber
        ENV['KNAPSACK_PRO_RECORDING_ENABLED'] = 'true'

        runner = new(KnapsackPro::Adapters::CucumberAdapter)

        require 'cucumber/rake/task'

        task_name = :features
        if Rake::Task.task_defined?(task_name)
          Rake::Task[task_name].clear
        end

        Cucumber::Rake::Task.new(:features) do |t|
          t.cucumber_opts = "#{args} -- #{runner.stringify_test_file_paths}"
        end
        Rake::Task[task_name].invoke
      end
    end
  end
end
