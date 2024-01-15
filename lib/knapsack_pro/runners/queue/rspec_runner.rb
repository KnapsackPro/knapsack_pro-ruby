# frozen_string_literal: true

require 'forwardable'

module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        extend Forwardable

        attr_reader :rspec_runner, :node_assigned_test_file_paths
        attr_accessor :rspec_configuration_options

        def_delegators :@rspec_runner, :world, :options, :configuration, :exit_code, :configure

        def run(rspec_runner)
          @node_assigned_test_file_paths = []
          @rspec_runner = rspec_runner

          # Abstract from #setup, since we do not need to set any filters or files at this point,
          # and we do not want to let world.announce_filters to be called, since it will print
          # out `No examples found.` message.
          configure($stderr, $stdout)
          world.__send__(:fail_if_config_and_cli_options_invalid)

          return configuration.reporter.exit_early(exit_code) if world.wants_to_quit

          _exit_status = run_specs
        end

        private

        def load_spec_files(files)
          world.reset
          filter_manager = RSpec::Core::FilterManager.new
          # TODO refactor private RSpec API
          rspec_configuration_options.configure_filter_manager(filter_manager)
          configuration.filter_manager = filter_manager

          configuration.__send__(:get_files_to_run, files).each do |f|
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

        def knapsack_pro_batches
          test_file_paths = pull_tests_from_queue(can_initialize_queue: true)

          until test_file_paths.empty?
            with_queue_hooks(test_file_paths) do |wrapped|
              yield wrapped
            end

            test_file_paths = pull_tests_from_queue
          end

          yield nil
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L113
        def run_specs
          ordering_strategy = configuration.ordering_registry.fetch(:global)

          configuration.with_suite_hooks do
            exit_status = configuration.reporter.report(0) do |reporter|
              knapsack_pro_batches do |files|
                break 0 unless files

                load_spec_files(files)

                examples_count = world.example_count(world.example_groups)

                if examples_count == 0 && configuration.fail_if_no_examples
                  break configuration.failure_exit_code
                else
                  batch_result = exit_code(ordering_strategy.order(world.example_groups).map { |g| g.run(reporter) }.all?)

                  break batch_result if batch_result != 0
                end
              end
            end

            exit_status
          end
        end

        def with_queue_hooks(files)
          subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
          ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

          KnapsackPro::Hooks::Queue.call_before_subset_queue

          yield files

          if world.wants_to_quit
            KnapsackPro.logger.warn('RSpec wants to quit.')
            self.class.set_terminate_process
          end
          if world.respond_to?(:rspec_is_quitting) && world.rspec_is_quitting
            KnapsackPro.logger.warn('RSpec is quitting.')
            self.class.set_terminate_process
          end

          self.class.log_rspec_command(files, :subset_queue)

          KnapsackPro::Hooks::Queue.call_after_subset_queue
        end

        class << self
          def run(args)
            require 'rspec/core'
            require_relative '../../formatters/time_tracker'
            require_relative '../../formatters/time_tracker_fetcher'
            require_relative '../../formatters/rspec_queue_summary_formatter'
            require_relative '../../formatters/rspec_queue_profile_formatter_extension'

            ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
            ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
            ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

            KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)

            # Initialize queue_runner to trap signals before RSpec::Core::Runner.run is called
            queue_runner = new(adapter_class)

            cli_args = (args || '').split
            adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(cli_args)

            # when format option is not defined by user then use progress formatter to show tests execution progress
            cli_args += ['--format', 'progress'] unless adapter_class.has_format_option?(cli_args)

            cli_args += [
              # shows summary of all tests executed in Queue Mode at the very end
              '--format', KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s,
              '--format', KnapsackPro::Formatters::TimeTracker.to_s,
              '--default-path', queue_runner.test_dir,
            ]

            ensure_spec_opts_have_knapsack_pro_formatters
            rspec_configuration_options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
            queue_runner.rspec_configuration_options = rspec_configuration_options

            rspec_runner = ::RSpec::Core::Runner.new(rspec_configuration_options)

            @printable_args = args_with_seed_option_added_when_viable(cli_args, rspec_runner)

            begin
              exit_code = queue_runner.run(rspec_runner)
            rescue Exception => exception
              KnapsackPro.logger.error("Having exception when running RSpec: #{exception.inspect}")
              KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_exit_summary(queue_runner.node_assigned_test_file_paths)
              raise
            end

            KnapsackPro::Adapters::RSpecAdapter.verify_bind_method_called

            KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_summary
            KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension.print_summary

            log_rspec_command(queue_runner.node_assigned_test_file_paths, :end_of_queue)

            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            KnapsackPro::Report.save_node_queue_to_api(time_tracker&.queue(queue_runner.node_assigned_test_file_paths))

            Kernel.exit(exit_code)
          end

          def log_rspec_command(test_file_paths, type)
            case type
            when :subset_queue
              KnapsackPro.logger.info("To retry the last batch of tests fetched from the API Queue, please run the following command on your machine:")
            when :end_of_queue
              KnapsackPro.logger.info("To retry all the tests assigned to this CI node, please run the following command on your machine:")
            end

            stringified_cli_args = @printable_args.join(' ')
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
