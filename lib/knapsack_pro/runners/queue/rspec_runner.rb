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
          run_tests(runner, true, cli_args, 0, [])
        end

        def self.run_tests(runner, can_initialize_queue, args, exitstatus, all_test_file_paths)
          test_file_paths = runner.test_file_paths(can_initialize_queue: can_initialize_queue)

          if test_file_paths.empty?
            unless all_test_file_paths.empty?
              cli_args = args + all_test_file_paths

              log_rspec_command(cli_args, :end_of_queue)
            end

            KnapsackPro::Report.save_node_queue_to_api
            exit(exitstatus)
          else
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            all_test_file_paths += test_file_paths
            cli_args = args + test_file_paths

            log_rspec_command(cli_args, :subset_queue)

            options = RSpec::Core::ConfigurationOptions.new(cli_args)
            exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
            exitstatus = exit_code if exit_code != 0
            RSpec.world.example_groups.clear

            run_tests(runner, false, args, exitstatus, all_test_file_paths)
          end
        end

        private

        def self.log_rspec_command(cli_args, type)
          case type
          when :subset_queue
            KnapsackPro.logger.info("To retry in development the subset of tests fetched from API queue please run below command on your machine. If you use --order random then remember to add proper --seed 123 that you will find at the end of rspec command.")
          when :end_of_queue
            KnapsackPro.logger.info("To retry in development the tests for this CI node please run below command on your machine. It will run all tests in a single run. If you need to reproduce a particular subset of tests fetched from API queue then above after each request to Knapsack Pro API you will find example rspec command.")
          end
          KnapsackPro.logger.info("bundle exec rspec " + cli_args.join(' '))
        end
      end
    end
  end
end
