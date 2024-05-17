# frozen_string_literal: true

module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        def self.run(args, stream_error = $stderr, stream_out = $stdout)
          require 'rspec/core'
          require_relative '../../extensions/rspec_extension'
          require_relative '../../formatters/time_tracker'
          require_relative '../../formatters/time_tracker_fetcher'

          KnapsackPro::Extensions::RSpecExtension.setup!

          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec

          rspec_pure = KnapsackPro::Pure::Queue::RSpecPure.new

          queue_runner = new(KnapsackPro::Adapters::RSpecAdapter, rspec_pure, args, stream_error, stream_out)
          queue_runner.run
        end

        def initialize(adapter_class, rspec_pure, args, stream_error, stream_out)
          super(adapter_class)
          @adapter_class = adapter_class
          @rspec_pure = rspec_pure
          args_array = (args || '').split
          has_format_option = @adapter_class.has_format_option?(args_array)
          has_require_rails_helper_option = @adapter_class.has_require_rails_helper_option?(args_array)
          rails_helper_exists = @adapter_class.rails_helper_exists?(test_dir)
          @cli_args = rspec_pure.prepare_cli_args(args, has_format_option, has_require_rails_helper_option, rails_helper_exists, test_dir)
          @stream_error = stream_error
          @stream_out = stream_out
          @node_test_file_paths = []
          @rspec_runner = nil # RSpec::Core::Runner is lazy initialized
          @queue = KnapsackPro::Queue.new
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
          end

          begin
            exit_code = @rspec_runner.knapsack__run_specs(self)
          rescue KnapsackPro::Runners::Queue::BaseRunner::TerminationError
            exit_code = @rspec_pure.error_exit_code(@rspec_runner.knapsack__error_exit_code)
            Kernel.exit(exit_code)
          rescue Exception => exception
            KnapsackPro.logger.error("An unexpected exception happened. RSpec cannot handle it. The exception: #{exception.inspect}")
            KnapsackPro.logger.error("Exception message: #{exception.message}")
            KnapsackPro.logger.error("Exception backtrace: #{exception.backtrace.join("\n")}")

            message = @rspec_pure.exit_summary(unexecuted_test_files)
            KnapsackPro.logger.warn(message) if message

            exit_code = @rspec_pure.error_exit_code(@rspec_runner.knapsack__error_exit_code)
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

            @queue.add_batch_for(test_file_paths)

            KnapsackPro::Hooks::Queue.call_before_subset_queue(@queue)

            yield test_file_paths, @queue

            KnapsackPro::Hooks::Queue.call_after_subset_queue(@queue)

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
          KnapsackPro.logger.warn('Test execution has been canceled because the RSpec --fail-fast option is enabled. It will cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')
        end

        private

        def pre_run_setup
          ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
          ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

          KnapsackPro::Config::Env.set_test_runner_adapter(@adapter_class)

          ENV['SPEC_OPTS'] = @rspec_pure.add_knapsack_pro_formatters_to(ENV['SPEC_OPTS'])
          @adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(@cli_args)

          rspec_configuration_options = ::RSpec::Core::ConfigurationOptions.new(@cli_args)
          @rspec_runner = ::RSpec::Core::Runner.new(rspec_configuration_options)
          @rspec_runner.knapsack__setup(@stream_error, @stream_out)

          ensure_no_deprecated_run_all_when_everything_filtered_option!
        end

        def post_run_tasks(exit_code)
          @adapter_class.verify_bind_method_called

          log_rspec_queue_command

          time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
          KnapsackPro::Report.save_node_queue_to_api(time_tracker&.queue(@node_test_file_paths))

          Kernel.exit(exit_code)
        end

        def ensure_no_deprecated_run_all_when_everything_filtered_option!
          return unless @rspec_runner.knapsack__deprecated_run_all_when_everything_filtered_enabled?

          error_message = "The run_all_when_everything_filtered option is deprecated. See: #{KnapsackPro::Urls::RSPEC__DEPRECATED_RUN_ALL_WHEN_EVERYTHING_FILTERED}"
          KnapsackPro.logger.error(error_message)
          raise error_message
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
          order_option = @adapter_class.order_option(@cli_args)
          printable_args = @rspec_pure.args_with_seed_option_added_when_viable(order_option, @rspec_runner.knapsack__seed, @cli_args)
          messages = @rspec_pure.rspec_command(printable_args, test_file_paths, :batch_finished)
          log_info_messages(messages)
        end

        def log_rspec_queue_command
          order_option = @adapter_class.order_option(@cli_args)
          printable_args = @rspec_pure.args_with_seed_option_added_when_viable(order_option, @rspec_runner.knapsack__seed, @cli_args)
          messages = @rspec_pure.rspec_command(printable_args, @node_test_file_paths, :queue_finished)
          log_info_messages(messages)
        end

        def log_info_messages(messages)
          messages.each do |message|
            KnapsackPro.logger.info(message)
          end
        end

        def unexecuted_test_files
          KnapsackPro::Formatters::TimeTrackerFetcher.unexecuted_test_files(@node_test_file_paths)
        end
      end
    end
  end
end
