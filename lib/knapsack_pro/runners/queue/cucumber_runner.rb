module KnapsackPro
  module Runners
    module Queue
      class CucumberRunner < BaseRunner
        def self.run(args)
          require 'cucumber/rake/task'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_cucumber
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          runner = new(KnapsackPro::Adapters::CucumberAdapter)

          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: args,
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

            result = cucumber_run(runner, test_file_paths, args)
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

        def self.cucumber_run(runner, test_file_paths, args)
          task_name = "knapsack_pro:cucumber_run:#{ENV.fetch('KNAPSACK_PRO_SUBSET_QUEUE_ID')}"
          stringify_test_file_paths = KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)

          puts 'S'*100
          Cucumber::Rake::Task.new(task_name) do |t|
            t.cucumber_opts = "#{args} --require #{runner.test_dir} -- #{stringify_test_file_paths}"
          end
          #Rake::Task[task_name].invoke
          Rake::Task[task_name].execute
          puts 'A'*100

          r = $?.exitstatus
          puts '$'*100
          puts r
        end
      end
    end
  end
end
