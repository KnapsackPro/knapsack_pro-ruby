# frozen_string_literal: true

require 'forwardable'

module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        class Core
          ADAPTER_CLASS = KnapsackPro::Adapters::RSpecAdapter
          FAILURE_EXIT_CODE = 1
          FORMATTERS = [
            'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
            'KnapsackPro::Formatters::TimeTracker',
          ]

          class << self
            def ensure_no_deprecated_run_all_when_everything_filtered_option!(deprecated_run_all_when_everything_filtered_enabled)
              return unless deprecated_run_all_when_everything_filtered_enabled

              error_message = "The run_all_when_everything_filtered option is deprecated. See: #{KnapsackPro::Urls::RSPEC__DEPRECATED_RUN_ALL_WHEN_EVERYTHING_FILTERED}"
              KnapsackPro.logger.error(error_message)
              raise error_message
            end

            def ensure_spec_opts_have_knapsack_pro_formatters
              spec_opts = ENV['SPEC_OPTS']

              return unless spec_opts
              return if FORMATTERS.all? { |formatter| spec_opts.include?(formatter) }

              FORMATTERS.each do |formatter|
                next if spec_opts.include?(formatter)
                spec_opts += " --format #{formatter}"
              end

              ENV['SPEC_OPTS'] = spec_opts
            end

            def error_exit_code(rspec_error_exit_code)
              rspec_error_exit_code || FAILURE_EXIT_CODE
            end

            def to_cli_args(args)
              (args || '').split
            end

            # @param args Array[String]
            def args_with_seed_option_added_when_viable(rspec_runner, args)
              order_option = ADAPTER_CLASS.order_option(args)

              if order_option
                # Don't add the seed option for order other than random, e.g. `defined`
                return args unless order_option.include?('rand')
                # Don't add the seed option if the seed is already set in args, e.g. `rand:12345`
                return args if order_option.to_s.split(':')[1]
              end

              # Don't add the seed option if the seed was not used (i.e. a different order is being used, e.g. `defined`)
              return args unless rspec_runner.knapsack__seed_used?

              args + ['--seed', rspec_runner.knapsack__seed]
            end

            # @param args Array[String]
            def ensure_args_have_default_formatter(args)
              return args if Core::ADAPTER_CLASS.has_format_option?(args)

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

            def log_rspec_command(args, test_file_paths, type)
              case type
              when :subset_queue
                KnapsackPro.logger.info("To retry the last batch of tests fetched from the API Queue, please run the following command on your machine:")
              when :end_of_queue
                KnapsackPro.logger.info("To retry all the tests assigned to this CI node, please run the following command on your machine:")
              end

              stringified_cli_args = args.join(' ')
              FORMATTERS.each do |formatter|
                stringified_cli_args.sub!(" --format #{formatter}", '')
              end

              KnapsackPro.logger.info(
                "bundle exec rspec #{stringified_cli_args} " +
                KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
              )
            end
          end
        end

        def initialize(adapter_class, args)
          super(adapter_class)
          @adapter_class = adapter_class
          @node_assigned_test_file_paths = []
          @cli_args = prepare_cli_args(args)
          @rspec_runner = nil # lazy initialization of RSpec::Core::Runner
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L85
        #
        # @return [Fixnum] exit status code.
        #   0 if all specs passed,
        #   or the configured failure exit code (1 by default) if specs failed.
        def run
          pre_run_setup

          return @rspec_runner.knapsack__exit_early if @rspec_runner.knapsack__wants_to_quit?

          begin
            exit_code = @rspec_runner.run_specs(self, KnapsackPro.logger)
          rescue KnapsackPro::Runners::Queue::BaseRunner::TerminationError
            @rspec_runner.knapsack__error_exit_code
              .yield_self { Core.error_exit_code(_1) }
              .yield_self { Kernel.exit(_1) }
            raise
          rescue Exception => exception
            KnapsackPro.logger.error("Having exception when running RSpec: #{exception.inspect}")
            KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_exit_summary(@node_assigned_test_file_paths)
            @rspec_runner.knapsack__error_exit_code
              .yield_self { Core.error_exit_code(_1) }
              .yield_self { Kernel.exit(_1) }
            raise
          end

          post_run_tasks(exit_code)
        end

        def with_batched_tests_from_queue
          can_initialize_queue = true

          loop do
            handle_signal!
            test_file_paths = pull_tests_from_queue(can_initialize_queue: can_initialize_queue)
            can_initialize_queue = false

            break if test_file_paths.empty?

            with_queue_hooks(test_file_paths) do |wrapped_test_file_paths|
              yield wrapped_test_file_paths
            end
          end
        end

        def handle_signal!
          self.class.handle_signal!
        end

        private

        def prepare_cli_args(args)
          cli_args = Core.to_cli_args(args)
          cli_args = Core.ensure_args_have_default_formatter(cli_args)
          Core.args_with_default_options(cli_args, test_dir)
        end

        def pre_run_setup
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          KnapsackPro::Config::Env.set_test_runner_adapter(@adapter_class)

          Core.ensure_spec_opts_have_knapsack_pro_formatters
          @adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(@cli_args)

          rspec_configuration_options = ::RSpec::Core::ConfigurationOptions.new(@cli_args)
          @rspec_runner = ::RSpec::Core::Runner.new(rspec_configuration_options)
          @rspec_runner.knapsack__setup

          Core.ensure_no_deprecated_run_all_when_everything_filtered_option!(@rspec_runner.knapsack__deprecated_run_all_when_everything_filtered_enabled?)
        end

        def post_run_tasks(exit_code)
          @adapter_class.verify_bind_method_called

          KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_summary
          KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension.print_summary

          printable_args = Core.args_with_seed_option_added_when_viable(@rspec_runner, @cli_args)
          Core.log_rspec_command(printable_args, @node_assigned_test_file_paths, :end_of_queue)

          time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
          KnapsackPro::Report.save_node_queue_to_api(time_tracker&.queue(@node_assigned_test_file_paths))

          Kernel.exit(exit_code)
        end

        def pull_tests_from_queue(can_initialize_queue: false)
          test_file_paths = test_file_paths(
            can_initialize_queue: can_initialize_queue,
            executed_test_files: @node_assigned_test_file_paths
          )
          @node_assigned_test_file_paths += test_file_paths
          test_file_paths
        end

        def with_queue_hooks(test_file_paths)
          subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
          ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

          KnapsackPro::Hooks::Queue.call_before_subset_queue

          yield test_file_paths

          if @rspec_runner.knapsack__wants_to_quit?
            KnapsackPro.logger.warn('RSpec wants to quit.')
            self.class.set_terminate_process
          end
          if @rspec_runner.knapsack__rspec_is_quitting?
            KnapsackPro.logger.warn('RSpec is quitting.')
            self.class.set_terminate_process
          end

          printable_args = Core.args_with_seed_option_added_when_viable(@rspec_runner, @cli_args)
          Core.log_rspec_command(printable_args, test_file_paths, :subset_queue)

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

            queue_runner = new(Core::ADAPTER_CLASS, args)
            queue_runner.run
          end
        end
      end
    end
  end
end
