# frozen_string_literal: true

module KnapsackPro
  module Runners
    module Queue
      # Imperative Shell [instance of KnapsackPro::Runners::Queue::RSpecRunner]
      # Architecture based on: https://www.destroyallsoftware.com/talks/boundaries
      #
      # It should contain calls to RSpec methods.
      # Preferably via methods with the  `knapsack__` prefix.
      # We want to isolate the imperative shell from the internals of RSpec.
      # It should be tested via integration tests if possible.
      # Alternatively, it should be tested using E2E tests on CI that are running against a Rails app with the RSpec test suite.
      class RSpecRunner < BaseRunner
        # Functional Core.
        # Architecture based on: https://www.destroyallsoftware.com/talks/boundaries
        #
        # It has business logic related to how Knapsack Pro works.
        # It should be easy to unit test it.
        # It should NOT contain direct calls to RSpec.
        class FunctionalCore
          FAILURE_EXIT_CODE = 1
          FORMATTERS = [
            'KnapsackPro::Formatters::TimeTracker',
          ]

          attr_reader :adapter_class

          def initialize(logger, adapter_class = KnapsackPro::Adapters::RSpecAdapter)
            @logger = logger
            @adapter_class = adapter_class
          end

          def ensure_no_deprecated_run_all_when_everything_filtered_option!(deprecated_run_all_when_everything_filtered_enabled)
            return unless deprecated_run_all_when_everything_filtered_enabled

            error_message = "The run_all_when_everything_filtered option is deprecated. See: #{KnapsackPro::Urls::RSPEC__DEPRECATED_RUN_ALL_WHEN_EVERYTHING_FILTERED}"
            logger.error(error_message)
            raise error_message
          end

          def ensure_spec_opts_have_knapsack_pro_formatters(spec_opts)
            return spec_opts unless spec_opts
            return spec_opts if FORMATTERS.all? { |formatter| spec_opts.include?(formatter) }

            FORMATTERS.each do |formatter|
              next if spec_opts.include?(formatter)
              spec_opts += " --format #{formatter}"
            end

            spec_opts
          end

          def error_exit_code(rspec_error_exit_code)
            rspec_error_exit_code || FAILURE_EXIT_CODE
          end

          def args_with_seed_option_added_when_viable(is_seed_used, seed, args)
            order_option = @adapter_class.order_option(args)

            if order_option
              return args unless order_option.include?('rand')
              return args if order_option.to_s.split(':')[1]
            end

            return args unless is_seed_used

            args + ['--seed', seed]
          end

          # @param args Array[String]
          def ensure_args_have_a_formatter(args)
            return args if @adapter_class.has_format_option?(args)

            args + ['--format', 'progress']
          end

          # @param args Array[String]
          def args_with_default_options(args, test_dir)
            new_args = args + [
              '--default-path', test_dir,
            ]

            FORMATTERS.each do |formatter|
              new_args += ['--format', formatter]
            end

            new_args
          end

          def log_rspec_command(args, test_file_paths, scope)
            return if test_file_paths.empty?

            case scope
            when :batch_finished
              logger.info('To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:')
            when :queue_finished
              logger.info('To retry all the tests assigned to this CI node, please run the following command on your machine:')
            end

            stringified_cli_args = args.join(' ')
            FORMATTERS.each do |formatter|
              stringified_cli_args.sub!(" --format #{formatter}", '')
            end

            logger.info(
              "bundle exec rspec #{stringified_cli_args} " +
              KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
            )
          end

          def log_fail_fast_limit_met
            logger.warn('Test execution has been canceled because the RSpec --fail-fast option is enabled. It will cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')
          end

          def log_exit_summary(node_test_file_paths)
            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            return unless time_tracker

            unexecuted_test_files = time_tracker.unexecuted_test_files(node_test_file_paths)
            return if unexecuted_test_files.empty?

            logger.warn("Unexecuted tests on this CI node (including pending tests): #{unexecuted_test_files.join(' ')}")
          end

          private

          attr_reader :logger
        end

        class << self
          def run(args, stream_error = $stderr, stream_out = $stdout, logger = KnapsackPro.logger)
            require 'rspec/core'
            require_relative '../../extensions/rspec_extension'
            require_relative '../../formatters/time_tracker'
            require_relative '../../formatters/time_tracker_fetcher'

            KnapsackPro::Extensions::RSpecExtension.setup!

            ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec

            functional_core = FunctionalCore.new(logger)

            queue_runner = new(functional_core.adapter_class, functional_core, args, stream_error, stream_out)
            queue_runner.run
          end
        end

        def initialize(adapter_class, functional_core, args, stream_error, stream_out)
          super(adapter_class)
          @adapter_class = adapter_class
          @functional_core = functional_core
          @cli_args = prepare_cli_args(args)
          @stream_error = stream_error
          @stream_out = stream_out
          @node_test_file_paths = []
          @rspec_runner = nil # RSpec::Core::Runner is lazy initialized
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L85
        #
        # @return [Fixnum] exit status code.
        #   0 if all specs passed,
        #   or the configured failure exit code (1 by default) if specs failed.
        def run
          pre_run_setup

          if @rspec_runner.knapsack__wants_to_quit?
            exit_code = @rspec_runner.knapsack__exit_early
            Kernel.exit(exit_code)
            return
          end

          begin
            exit_code = @rspec_runner.knapsack__run_specs(self)
          rescue KnapsackPro::Runners::Queue::BaseRunner::TerminationError
            exit_code = @functional_core.error_exit_code(@rspec_runner.knapsack__error_exit_code)
            Kernel.exit(exit_code)
          rescue Exception => exception
            KnapsackPro.logger.error("An unexpected exception happened. RSpec cannot handle it. The exception: #{exception.inspect}")
            @functional_core.log_exit_summary(@node_test_file_paths)
            exit_code = @functional_core.error_exit_code(@rspec_runner.knapsack__error_exit_code)
            Kernel.exit(exit_code)
          end

          post_run_tasks(exit_code)
        end

        def with_batch
          can_initialize_queue = true

          loop do
            handle_signal!
            test_file_paths = pull_tests_from_queue(can_initialize_queue: can_initialize_queue)
            can_initialize_queue = false

            break if test_file_paths.empty?

            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            KnapsackPro::Hooks::Queue.call_before_subset_queue

            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            time_tracker&.batch_started

            yield test_file_paths

            KnapsackPro::Hooks::Queue.call_after_subset_queue

            if @rspec_runner.knapsack__wants_to_quit?
              KnapsackPro.logger.warn('RSpec wants to quit.')
              set_terminate_process
            end
            if @rspec_runner.knapsack__rspec_is_quitting?
              KnapsackPro.logger.warn('RSpec is quitting.')
              set_terminate_process
            end

            log_rspec_batch_command(test_file_paths)
          end
        end

        def handle_signal!
          self.class.handle_signal!
        end

        def log_fail_fast_limit_met
          @functional_core.log_fail_fast_limit_met
        end

        private

        def prepare_cli_args(args)
          cli_args = (args || '').split
          cli_args = @functional_core.ensure_args_have_a_formatter(cli_args)
          @functional_core.args_with_default_options(cli_args, test_dir)
        end

        def pre_run_setup
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          KnapsackPro::Config::Env.set_test_runner_adapter(@adapter_class)

          ENV['SPEC_OPTS'] = @functional_core.ensure_spec_opts_have_knapsack_pro_formatters(ENV['SPEC_OPTS'])
          @adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(@cli_args)

          rspec_configuration_options = ::RSpec::Core::ConfigurationOptions.new(@cli_args)
          @rspec_runner = ::RSpec::Core::Runner.new(rspec_configuration_options)
          @rspec_runner.knapsack__setup(@stream_error, @stream_out)

          @functional_core.ensure_no_deprecated_run_all_when_everything_filtered_option!(@rspec_runner.knapsack__deprecated_run_all_when_everything_filtered_enabled?)
        end

        def post_run_tasks(exit_code)
          @adapter_class.verify_bind_method_called

          log_rspec_queue_command

          time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
          KnapsackPro::Report.save_node_queue_to_api(time_tracker&.queue(@node_test_file_paths))

          Kernel.exit(exit_code)
        end

        def pull_tests_from_queue(can_initialize_queue: false)
          test_file_paths = test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: @node_test_file_paths
          )
          @node_test_file_paths += test_file_paths
          test_file_paths
        end

        def log_rspec_batch_command(test_file_paths)
          printable_args = @functional_core.args_with_seed_option_added_when_viable(@rspec_runner.knapsack__seed_used?, @rspec_runner.knapsack__seed, @cli_args)
          @functional_core.log_rspec_command(printable_args, test_file_paths, :batch_finished)
        end

        def log_rspec_queue_command
          printable_args = @functional_core.args_with_seed_option_added_when_viable(@rspec_runner.knapsack__seed_used?, @rspec_runner.knapsack__seed, @cli_args)
          @functional_core.log_rspec_command(printable_args, @node_test_file_paths, :queue_finished)
        end
      end
    end
  end
end
