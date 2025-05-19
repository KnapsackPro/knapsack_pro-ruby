# frozen_string_literal: true

module KnapsackPro
  module Runners
    module Queue
      class CucumberRunner < BaseRunner
        def self.run(args)
          require 'cucumber/rake/task'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_cucumber
          ENV['KNAPSACK_PRO_QUEUE_MODE_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          adapter_class = KnapsackPro::Adapters::CucumberAdapter
          KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)
          runner = new(adapter_class)

          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: args,
            exitstatus: 0,
            node_test_file_paths: [],
          }
          while accumulator[:status] == :next
            handle_signal!
            accumulator = run_tests(accumulator)
          end

          Kernel.exit(accumulator[:exitstatus])
        rescue KnapsackPro::QueueAllocator::FallbackModeError
          exit_code = KnapsackPro::Config::Env.fallback_mode_error_exit_code
          Kernel.exit(exit_code)
        end

        def self.run_tests(accumulator)
          runner = accumulator.fetch(:runner)
          can_initialize_queue = accumulator.fetch(:can_initialize_queue)
          args = accumulator.fetch(:args)
          exitstatus = accumulator.fetch(:exitstatus)
          node_test_file_paths = accumulator.fetch(:node_test_file_paths)

          test_file_paths = runner.test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: node_test_file_paths
          )

          if test_file_paths.empty?
            unless node_test_file_paths.empty?
              KnapsackPro::Adapters::CucumberAdapter.verify_bind_method_called
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

            KnapsackPro::Hooks::Queue.call_before_subset_queue

            node_test_file_paths += test_file_paths

            result_exitstatus = cucumber_run(runner, test_file_paths, args)
            exitstatus = result_exitstatus if result_exitstatus != 0

            # KnapsackPro::Hooks::Queue.call_after_subset_queue
            # KnapsackPro::Report.save_subset_queue_to_file
            # are called in adapter: lib/knapsack_pro/adapters/cucumber_adapter.rb

            return {
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              node_test_file_paths: node_test_file_paths,
            }
          end
        end

        private

        def self.cucumber_run(runner, test_file_paths, args)
          cmd = [
            *to_array(KnapsackPro::Config::Env.cucumber_queue_prefix),
            'cucumber',
            *to_array(args),
            '--require',
            runner.test_dir,
            '--',
            *test_file_paths
          ].compact

          Kernel.system(*cmd)

          # it must be set here so when we call next time above cmd we won't run again:
          # KnapsackPro::Hooks::Queue.call_before_queue
          # which is defined in lib/knapsack_pro/adapters/cucumber_adapter.rb
          ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED'] = 'true'

          unless child_status.exited?
            raise "Cucumber process execution failed. It's likely that your CI server has exceeded"\
                    " its available memory. Please try changing CI config or retrying the CI build.\n"\
                    "Failed command: #{cmd.join(' ')}\n"\
                    "Process status: #{child_status.inspect}"
          end

          child_status.exitstatus
        end

        def self.to_array(args)
          args.to_s.split(' ')
        end
      end
    end
  end
end
