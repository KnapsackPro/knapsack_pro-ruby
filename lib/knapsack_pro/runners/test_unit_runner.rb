module KnapsackPro
  module Runners
    class TestUnitRunner < BaseRunner
      def self.run(args)
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_test_unit
        ENV['KNAPSACK_PRO_RECORDING_ENABLED'] = 'true'

        runner = new(KnapsackPro::Adapters::TestUnitAdapter)

        if runner.test_files_to_execute_exist?
          #require 'rspec/core/rake_task'

          #task_name = 'knapsack_pro:test_unit_run'
          #if Rake::Task.task_defined?(task_name)
            #Rake::Task[task_name].clear
          #end

          #RSpec::Core::RakeTask.new(task_name) do |t|
            #t.rspec_opts = "#{args} --default-path #{runner.test_dir}"
            #t.pattern = runner.test_file_paths
          #end
          #Rake::Task[task_name].invoke
        end
      end
    end
  end
end
