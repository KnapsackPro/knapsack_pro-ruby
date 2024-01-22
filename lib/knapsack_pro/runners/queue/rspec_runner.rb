# frozen_string_literal: true

require 'forwardable'

module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        extend Forwardable

        class Core
          FAILURE_EXIT_CODE = 1

          class << self
            def ensure_no_deprecated_options!(deprecated_run_all_when_everything_filtered_enabled)
              return unless deprecated_run_all_when_everything_filtered_enabled

              error_message = "The run_all_when_everything_filtered option is deprecated. See: #{KnapsackPro::Urls::RSPEC__DEPRECATED_RUN_ALL_WHEN_EVERYTHING_FILTERED}"
              KnapsackPro.logger.error(error_message)
              raise error_message
            end

            def error_exit_code(rspec_error_exit_code)
              rspec_error_exit_code || FAILURE_EXIT_CODE
            end

            def to_cli_args(args)
              (args || '').split
            end
          end
        end

        attr_reader :node_assigned_test_file_paths
        attr_accessor :rspec_configuration_options

        @@used_seed = nil
        @@cli_args = nil

        def_delegators :@rspec_runner, :world, :configuration, :exit_code

        def initialize(adapter_class)
          super
          @node_assigned_test_file_paths = []
          @rspec_runner = nil # lazy assigned instance of ::RSpec::Core::Runner
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L85
        #
        # @return [Fixnum] exit status code.
        #   0 if all specs passed,
        #   or the configured failure exit code (1 by default) if specs failed.
        def run(rspec_runner)
          @rspec_runner = rspec_runner

          rspec_runner.knapsack__setup
          Core.ensure_no_deprecated_options!(rspec_runner.knapsack__deprecated_run_all_when_everything_filtered_enabled?)

          return rspec_runner.knapsack__exit_early if rspec_runner.knapsack__wants_to_quit?

          begin
            run_specs
          rescue KnapsackPro::Runners::Queue::BaseRunner::TerminationError
            rspec_runner.knapsack__error_exit_code
              .yield_self { Core.error_exit_code(_1) }
              .yield_self { Kernel.exit(_1) }
            raise
          rescue Exception => exception
            KnapsackPro.logger.error("Having exception when running RSpec: #{exception.inspect}")
            KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_exit_summary(node_assigned_test_file_paths)
            rspec_runner.knapsack__error_exit_code
              .yield_self { Core.error_exit_code(_1) }
              .yield_self { Kernel.exit(_1) }
            raise
          end
        end

        private

        def load_spec_files(test_file_paths)
          world.reset
          filter_manager = RSpec::Core::FilterManager.new
          # TODO refactor private RSpec API
          rspec_configuration_options.configure_filter_manager(filter_manager)
          configuration.filter_manager = filter_manager

          configuration.__send__(:get_files_to_run, test_file_paths).each do |f|
            file = File.expand_path(f)
            configuration.__send__(:load_file_handling_errors, :load, file)
            configuration.loaded_spec_files << file
          end
        end

        def pull_tests_from_queue(can_initialize_queue: false)
          test_file_paths = test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: @node_assigned_test_file_paths
          )
          @node_assigned_test_file_paths += test_file_paths
          test_file_paths
        end

        def with_batched_tests_from_queue
          can_initialize_queue = true

          loop do
            self.class.handle_signal!
            test_file_paths = pull_tests_from_queue(can_initialize_queue: can_initialize_queue)
            can_initialize_queue = false

            break if test_file_paths.empty?

            with_queue_hooks(test_file_paths) do |wrapped_test_file_paths|
              yield wrapped_test_file_paths
            end
          end
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L113
        #
        # Option: `configuration.fail_if_no_examples`
        #   Ignore the configuration.fail_if_no_examples option because it should be off in Queue Mode.
        #   * Ignore the fail_if_no_examples option because in Queue Mode a late CI node can start after other CI nodes already executed tests. It is expected to not run examples in such scenario.
        #   * RSpec should not fail when examples are not executed for a batch of tests fetched from Queue API. The batch could have tests that have no examples (for example, someone commented out the content of the spec file). We should fetch another batch of tests from Queue API and keep running tests.
        #
        # @return [Fixnum] exit status code.
        def run_specs
          # Based on:
          # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/world.rb#L53
          ordering_strategy = configuration.ordering_registry.fetch(:global)
          node_examples_passed = true

          configuration.with_suite_hooks do
            exit_status = configuration.reporter.report(_expected_example_count = 0) do |reporter|
              with_batched_tests_from_queue do |test_file_paths|
                load_spec_files(test_file_paths)

                examples_passed = ordering_strategy.order(world.example_groups).map do |example_group|
                  self.class.handle_signal!
                  example_group.run(reporter)
                end.all?

                node_examples_passed = false unless examples_passed

                if reporter.fail_fast_limit_met?
                  KnapsackPro.logger.warn('Test execution has been canceled because the RSpec --fail-fast option is enabled. It can cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')
                  break
                end
              end
            end

            exit_code(node_examples_passed)
          end
        end

        def with_queue_hooks(test_file_paths)
          subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
          ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

          KnapsackPro::Hooks::Queue.call_before_subset_queue

          yield test_file_paths

          if world.wants_to_quit
            KnapsackPro.logger.warn('RSpec wants to quit.')
            self.class.set_terminate_process
          end
          if world.respond_to?(:rspec_is_quitting) && world.rspec_is_quitting
            KnapsackPro.logger.warn('RSpec is quitting.')
            self.class.set_terminate_process
          end

          printable_args = self.class.args_with_seed_option_added_when_viable(@@cli_args, @rspec_runner)
          self.class.log_rspec_command(printable_args, test_file_paths, :subset_queue)

          KnapsackPro::Hooks::Queue.call_after_subset_queue
        end

        class << self
          def run(args)
            require 'rspec/core'
            require_relative '../../extensions/rspec_extension'
            require_relative '../../formatters/time_tracker'
            require_relative '../../formatters/time_tracker_fetcher'
            require_relative '../../formatters/rspec_queue_summary_formatter'
            require_relative '../../formatters/rspec_queue_profile_formatter_extension'

            KnapsackPro::Extensions::RSpecExtension.setup!

            ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
            ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
            ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

            KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)

            # Initialize queue_runner to trap signals before RSpec::Core::Runner is called
            queue_runner = new(adapter_class)

            cli_args = Core.to_cli_args(args)
            adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(cli_args)

            # when format option is not defined by user then use progress formatter to show tests execution progress
            cli_args += ['--format', 'progress'] unless adapter_class.has_format_option?(cli_args)

            cli_args += [
              # shows summary of all tests executed in Queue Mode at the very end
              '--format', KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s,
              '--format', KnapsackPro::Formatters::TimeTracker.to_s,
              '--default-path', queue_runner.test_dir,
            ]
            @@cli_args = cli_args

            ensure_spec_opts_have_knapsack_pro_formatters
            rspec_configuration_options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
            queue_runner.rspec_configuration_options = rspec_configuration_options

            rspec_runner = ::RSpec::Core::Runner.new(rspec_configuration_options)

            exit_code = queue_runner.run(rspec_runner)

            KnapsackPro::Adapters::RSpecAdapter.verify_bind_method_called

            KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_summary
            KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension.print_summary

            printable_args = args_with_seed_option_added_when_viable(cli_args, rspec_runner)
            log_rspec_command(printable_args, queue_runner.node_assigned_test_file_paths, :end_of_queue)

            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            KnapsackPro::Report.save_node_queue_to_api(time_tracker&.queue(queue_runner.node_assigned_test_file_paths))

            Kernel.exit(exit_code)
          end

          def log_rspec_command(args, test_file_paths, type)
            case type
            when :subset_queue
              KnapsackPro.logger.info("To retry the last batch of tests fetched from the API Queue, please run the following command on your machine:")
            when :end_of_queue
              KnapsackPro.logger.info("To retry all the tests assigned to this CI node, please run the following command on your machine:")
            end

            stringified_cli_args = args.join(' ')
              .sub(" --format #{KnapsackPro::Formatters::RSpecQueueSummaryFormatter}", '')
              .sub(" --format #{KnapsackPro::Formatters::TimeTracker}", '')

            KnapsackPro.logger.info(
              "bundle exec rspec #{stringified_cli_args} " +
              KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
            )
          end

          def args_with_seed_option_added_when_viable(args, rspec_runner)
            order_option = adapter_class.order_option(args)

            if order_option
              # Don't add the seed option for order other than random, e.g. `defined`
              return args unless order_option.include?('rand')
              # Don't add the seed option if the seed is already set in args, e.g. `rand:12345`
              return args if order_option.to_s.split(':')[1]
            end

            # Don't add the seed option if the seed was not used (i.e. a different order is being used, e.g. `defined`)
            return args unless rspec_runner.configuration.seed_used?

            @@used_seed = rspec_runner.configuration.seed.to_s

            args + ['--seed', @@used_seed]
          end

          private

          def adapter_class
            KnapsackPro::Adapters::RSpecAdapter
          end

          def ensure_spec_opts_have_knapsack_pro_formatters
            spec_opts = ENV['SPEC_OPTS']

            knapsack_pro_formatters = [
              KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s,
              KnapsackPro::Formatters::TimeTracker.to_s,
            ]

            return unless spec_opts
            return if knapsack_pro_formatters.all? { |formatter| spec_opts.include?(formatter) }

            knapsack_pro_formatters.each do |formatter|
              unless spec_opts.include?(formatter)
                spec_opts += " --format #{formatter}"
              end
            end

            ENV['SPEC_OPTS'] = spec_opts
          end
        end
      end
    end
  end
end
