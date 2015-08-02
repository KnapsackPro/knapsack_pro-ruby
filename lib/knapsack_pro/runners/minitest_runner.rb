module KnapsackPro
  module Runners
    class MinitestRunner
      def self.run(args)
        adapter_class = KnapsackPro::Adapters::MinitestAdapter
        allocator_builder = KnapsackPro::AllocatorBuilder.new(adapter_class)
        test_dir = allocator_builder.test_dir
        allocator = allocator_builder.allocator

        task_name = 'knapsack_pro:minitest_run'

        if Rake::Task.task_defined?(task_name)
          Rake::Task[task_name].clear
        end

        Rake::TestTask.new(task_name) do |t|
          t.libs << test_dir
          t.test_files = allocator.test_file_paths
          t.options = args
        end

        Rake::Task[task_name].invoke
      end
    end
  end
end
