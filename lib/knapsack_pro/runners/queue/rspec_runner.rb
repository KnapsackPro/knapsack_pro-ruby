module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          runner = new(KnapsackPro::Adapters::RSpecAdapter)

          cli_args = (args || '').split + [
            '--default-path', runner.test_dir,
          ]
          run_tests(runner, true, cli_args, 0)
        end

        def self.run_tests(runner, can_initialize_queue, args, exitstatus)
          test_file_paths = runner.test_file_paths(can_initialize_queue: can_initialize_queue)

          if test_file_paths.empty?
            KnapsackPro::Report.save_node_queue_to_api
            exit(exitstatus)
          else
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            cli_args = args + test_file_paths

            options = RSpec::Core::ConfigurationOptions.new(cli_args)
            exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
            exitstatus = exit_code if exit_code != 0
            RSpec.world.example_groups.clear

            run_tests(runner, false, args, exitstatus)
          end
        end
      end
    end
  end
end
