module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args)
          require 'rspec/core'
          require_relative '../../formatters/rspec_queue_summary_formatter'
          require_relative '../../formatters/rspec_queue_profile_formatter_extension'

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          adapter_class = KnapsackPro::Adapters::RSpecAdapter
          runner = new(adapter_class)
          test_file_pattern = TestFilePattern.call(adapter_class)
          test_file_paths = KnapsackPro::TestFileFinder.call(test_file_pattern)

          cli_args = [
            '--dry-run',
            '--format', 'json',
            '--default-path', runner.test_dir,
          ] + test_file_paths.map { |t| t.fetch('path') }
          options = RSpec::Core::ConfigurationOptions.new(cli_args)

          #fake_stdout = StringIO.new
          #exit_code = RSpec::Core::Runner.new(options).run($stderr, fake_stdout)
          exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
          if exit_code != 0
            raise 'There was problem to generate test examples for test suite'
          end
          example_ids = RSpec.world.all_examples.map(&:id)
          test_file_example_ids = example_ids.map { |id| KnapsackPro::TestFileCleaner.clean(id) }

          #RSpec.reset # resets dry-run but removes shared examples
          #RSpec.configuration.reset
          RSpec.clear_examples # first tests from Queue API won't run the whole test suite
          #RSpec.world.reset

          RSpec.configuration.reset_reporter # clears formatters
          #
          #RSpec.world.reset

          #rspec_clear_examples
          #RSpec.world.reset

          #RSpec.instance_variable_set(:@word, nil)
          #RSpec.instance_variable_set(:@configuration, nil)

          #RSpec.clear_examples

          #reset_options = RSpec::Core::ConfigurationOptions.new([])

          #require 'pry'; binding.pry

          # TODO
          # 1. how to reset formatter because json formatter is applied to further RSpec::Core::Runner executions despit we create a new instance of it
          # 2. when using fake_stdout then it's applied to further RSpec::Core::Runner but it should not
          #rspec_clear_examples

          # this removes formatters but also aciddentally removes before hooks like:
          # Expected correct output from tests with puts from hooks:
          # FooBar
          # before all
          # around each start
          # before each
          # after each
          # around each stop
          # should equal true
          #   .after all
          #RSpec.configuration.reset

          #RSpec.configuration.reset_reporter # clears formatters

          #RSpec.configure { |c| c.dry_run = false }
          #require 'pry'; binding.pry

          #require 'pry'; binding.pry
          #raise 'stop'


          cli_args = (args || '').split
          # if user didn't provide the format then use explicitly default progress formatter
          # in order to avoid KnapsackPro::Formatters::RSpecQueueSummaryFormatter being the only default formatter
          cli_args += ['--format', 'progress'] unless cli_args.include?('--format')
          cli_args += [
            '--format', KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s,
            '--default-path', runner.test_dir,
          ]

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
              KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_summary
              KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension.print_summary

              log_rspec_command(args, all_test_file_paths, :end_of_queue)
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
            cli_args = args + test_file_paths

            log_rspec_command(args, test_file_paths, :subset_queue)

            options = RSpec::Core::ConfigurationOptions.new(cli_args)
            exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
            exitstatus = exit_code if exit_code != 0

            rspec_clear_examples

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

        def self.log_rspec_command(cli_args, test_file_paths, type)
          case type
          when :subset_queue
            KnapsackPro.logger.info("To retry in development the subset of tests fetched from API queue please run below command on your machine. If you use --order random then remember to add proper --seed 123 that you will find at the end of rspec command.")
          when :end_of_queue
            KnapsackPro.logger.info("To retry in development the tests for this CI node please run below command on your machine. It will run all tests in a single run. If you need to reproduce a particular subset of tests fetched from API queue then above after each request to Knapsack Pro API you will find example rspec command.")
          end

          stringify_cli_args = cli_args.join(' ')
          stringify_cli_args.slice!("--format #{KnapsackPro::Formatters::RSpecQueueSummaryFormatter}")

          KnapsackPro.logger.info(
            "bundle exec rspec #{stringify_cli_args} " +
            KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
          )
        end

        # Clear rspec examples without the shared examples:
        # https://github.com/rspec/rspec-core/pull/2379
        #
        # Keep formatters and report to accumulate info about failed/pending tests
        def self.rspec_clear_examples
          if RSpec::ExampleGroups.respond_to?(:remove_all_constants)
            RSpec::ExampleGroups.remove_all_constants
          else
            RSpec::ExampleGroups.constants.each do |constant|
              RSpec::ExampleGroups.__send__(:remove_const, constant)
            end
          end
          RSpec.world.example_groups.clear
          RSpec.configuration.start_time = ::RSpec::Core::Time.now

          # skip reset filters for old RSpec versions
          if RSpec.configuration.respond_to?(:reset_filters)
            RSpec.configuration.reset_filters
          end
        end
      end
    end
  end
end
