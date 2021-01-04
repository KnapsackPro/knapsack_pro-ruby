module KnapsackPro
  module Runners
    module Queue
      class MinitestRunner < BaseRunner
        def self.run(args)
          require 'minitest'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_minitest
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          runner = new(KnapsackPro::Adapters::MinitestAdapter)

          # Add test_dir to load path to make work:
          #   require 'test_helper'
          # in test files.
          $LOAD_PATH.unshift(runner.test_dir)

          cli_args = (args || '').split

          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: cli_args,
            exitstatus: 0,
            all_test_file_paths: [],
          }
          while accumulator[:status] == :next
            accumulator = run_tests(accumulator)
          end

          Kernel.exit(accumulator[:exitstatus])
        end

        def self.run_tests(accumulator)
          runner = accumulator.fetch(:runner)
          can_initialize_queue = accumulator.fetch(:can_initialize_queue)
          args = accumulator.fetch(:args)
          exitstatus = accumulator.fetch(:exitstatus)
          all_test_file_paths = accumulator.fetch(:all_test_file_paths)

          test_file_paths = runner.test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: all_test_file_paths
          )

          if test_file_paths.empty?
            unless all_test_file_paths.empty?
              KnapsackPro::Adapters::MinitestAdapter.verify_bind_method_called
            end

            KnapsackPro::Hooks::Queue.call_after_queue

            KnapsackPro::Report.save_node_queue_to_api

            return {
              status: :completed,
              exitstatus: exitstatus,
            }
          else
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            KnapsackPro.tracker.reset!
            KnapsackPro.tracker.set_prerun_tests(test_file_paths)

            all_test_file_paths += test_file_paths

            result = minitest_run(runner, test_file_paths, args)
            exitstatus = 1 unless result

            KnapsackPro::Hooks::Queue.call_after_subset_queue

            KnapsackPro::Report.save_subset_queue_to_file

            return {
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              all_test_file_paths: all_test_file_paths,
            }
          end
        end

        private

        def self.minitest_run(runner, test_file_paths, args)
          test_file_paths.each do |test_file_path|
            require "./#{test_file_path}"
          end

          # duplicate args because Minitest modifies args
          result = ::Minitest.run(args.dup)

          ::Minitest::Runnable.reset

          result
        end
      end
    end
  end
end
