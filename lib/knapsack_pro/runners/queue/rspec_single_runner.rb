# frozen_string_literal: true

require 'forwardable'

module KnapsackPro
  module Runners
    module Queue
      class RSpecSingleRunner < BaseRunner
        class ProxyRunner
          extend Forwardable

          attr_reader :rspec_runner

          def_delegators :@rspec_runner, :world, :options, :configuration, :exit_code, :setup, :run_specs

          def initalize(rspec_runner, knapsack_pro_runner)
            @rspec_runner = rspec_runner
            @knapsack_pro_runner = knapsack_pro_runner
            @all_test_file_paths = []
          end

          def run
            setup($stderr, $stdout)
            return configuration.reporter.exit_early(exit_code) if world.wants_to_quit

            knapsack_pro_batches do |files|
              load_spec_files(files)

              exit_code_from_batch = run_specs(world.example_groups).tap do
                rspec_runner.send(:persist_example_statuses)
              end

              break exit_code_from_batch if exit_code_from_batch != 0
            end
          end

          def load_spec_files(files)
            # Reset example groups
            world.example_groups.clear

            files.each do |f|
              file = File.expand_path(f)
              configuration.send(:load_file_handling_errors, :load, file)
              configuration.loaded_spec_files << file
            end
          end

          def knapsack_pro_batches
            allocator = @knapsack_pro_runner.send(:allocator)
            files = allocator.test_file_paths(true, tests)

            until files.empty?
              yield with_hooks(files)

              files = allocator.test_file_paths(false, @all_test_file_paths)
            end
          end

          private

          def with_hooks(files)
            subset_queue_id = KnapsackPro::Config::EnvGenerator.set_subset_queue_id
            ENV['KNAPSACK_PRO_SUBSET_QUEUE_ID'] = subset_queue_id

            KnapsackPro.tracker.reset!
            KnapsackPro.tracker.set_prerun_tests(files)

            KnapsackPro::Hooks::Queue.call_before_subset_queue

            yield files

            @all_test_file_paths += files

            if world.wants_to_quit
              KnapsackPro.logger.warn('RSpec wants to quit.')
              @knapsack_pro_runner.class.set_terminate_process
            end
            if world.rspec_is_quitting
              KnapsackPro.logger.warn('RSpec is quitting.')
              @knapsack_pro_runner.class.set_terminate_process
            end

            KnapsackPro::Hooks::Queue.call_after_subset_queue

            KnapsackPro::Report.save_subset_queue_to_file
          end
        end

        class << self
          def run(args)
            require 'rspec/core'
            require_relative '../../formatters/rspec_queue_summary_formatter'
            require_relative '../../formatters/rspec_queue_profile_formatter_extension'

            ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
            ENV['KNAPSACK_PRO_QUEUE_RECORDING_ENABLED'] = 'true'
            ENV['KNAPSACK_PRO_QUEUE_ID'] = KnapsackPro::Config::EnvGenerator.set_queue_id

            KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)

            # Initialize runner to trap signals before RSpec::Core::Runner.run is called
            runner = new(adapter_class)

            cli_args = (args || '').split
            adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(cli_args)

            # when format option is not defined by user then use progress formatter to show tests execution progress
            cli_args += ['--format', 'progress'] unless adapter_class.has_format_option?(cli_args)

            cli_args += [
              # shows summary of all tests executed in Queue Mode at the very end
              '--format', KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s,
              '--default-path', runner.test_dir,
            ]

            ensure_spec_opts_have_rspec_queue_summary_formatter
            options = ::RSpec::Core::ConfigurationOptions.new(cli_args)

            rspec_runner = ::RSpec::Core::Runner.new(options)

            begin
              exit_code = ProxyRunner.new(rspec_runner, runner).run
              Kernel.exit(exit_code)
            rescue Exception => exception
              KnapsackPro.logger.error("Having exception when running RSpec: #{exception.inspect}")
              KnapsackPro::Formatters::RSpecQueueSummaryFormatter.print_exit_summary
              KnapsackPro::Hooks::Queue.call_after_subset_queue
              KnapsackPro::Hooks::Queue.call_after_queue
              Kernel.exit(1)
              raise
            end
          end

          private

          def adapter_class
            KnapsackPro::Adapters::RSpecAdapter
          end

          def ensure_spec_opts_have_rspec_queue_summary_formatter
            spec_opts = ENV['SPEC_OPTS']

            return unless spec_opts
            return if spec_opts.include?(KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s)

            ENV['SPEC_OPTS'] = "#{spec_opts} --format #{KnapsackPro::Formatters::RSpecQueueSummaryFormatter.to_s}"
          end
        end
      end
    end
  end
end
