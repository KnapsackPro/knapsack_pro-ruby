module KnapsackPro
  module Runners
    class MinitestRunner < BaseRunner
      def self.run(args)
        runner = new(KnapsackPro::Adapters::MinitestAdapter)

        task_name = 'knapsack_pro:minitest_run'

        if Rake::Task.task_defined?(task_name)
          Rake::Task[task_name].clear
        end

        Rake::TestTask.new(task_name) do |t|
          t.libs << runner.test_dir
          t.test_files = runner.test_file_paths
          t.options = args
        end

        Rake::Task[task_name].invoke
      end
    end
  end
end
