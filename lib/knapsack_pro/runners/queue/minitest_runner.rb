module KnapsackPro
  module Runners
    module Queue
      class MinitestRunner < BaseRunner
        def self.run(args)
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_minitest
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          runner = new(KnapsackPro::Adapters::MinitestAdapter)

          run_tests(runner, true, args, 0, [])
        end

        def self.run_tests(runner, can_initialize_queue, args, exitstatus, all_test_file_paths)
          test_file_paths = runner.test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: all_test_file_paths
          )

          if test_file_paths.empty?
            KnapsackPro::Hooks::Queue.call_after_queue

            KnapsackPro::Report.save_node_queue_to_api
            exit(exitstatus)
          else
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            all_test_file_paths += test_file_paths

            minitest_run(runner, test_file_paths, args, all_test_file_paths.size)
            exit_code = $?

            exitstatus = exit_code if exit_code != 0

            KnapsackPro::Hooks::Queue.call_after_subset_queue

            run_tests(runner, false, args, exitstatus, all_test_file_paths)
          end
        end

        private

        def self.minitest_run(runner, test_file_paths, args, unique_index)
          task_name = "knapsack_pro:queue:minitest_run_#{unique_index}"

          if Rake::Task.task_defined?(task_name)
            Rake::Task[task_name].clear
          end

          Rake::TestTask.new(task_name) do |t|
            t.warning = false
            t.libs << runner.test_dir
            t.test_files = test_file_paths
            t.options = args
          end

          Rake::Task[task_name].invoke
        end
      end
    end
  end
end
