module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core/rake_task'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          runner = new(KnapsackPro::Adapters::RSpecAdapter)
          run_tests(runner, true, args, 0)
        end

        def self.run_tests(runner, can_initialize_queue, args, exitstatus)
          test_file_paths = runner.test_file_paths(can_initialize_queue: can_initialize_queue)

          if test_file_paths.empty?
            KnapsackPro::Report.save_node_queue_to_api
            exit(exitstatus)
          else
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id
            task_name = "knapsack_pro:queue:rspec_run_#{subset_queue_id}"

            RSpec::Core::RakeTask.new(task_name) do |t|
              t.rspec_opts = "#{args} --default-path #{runner.test_dir}"
              t.pattern = test_file_paths
            end

            begin
              Rake::Task[task_name].invoke
            rescue Exception => e
              puts "Task failed: #{task_name}"
              puts "#{e.class}: #{e.message}"
              puts "Exit status: #{$?.exitstatus}"
              exitstatus = $?.exitstatus if $?.exitstatus != 0
            end

            at_exit do
              run_tests(runner, false, args, exitstatus)
            end
          end
        end
      end
    end
  end
end
