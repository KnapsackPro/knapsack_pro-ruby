# frozen_string_literal: true

module KnapsackPro
  module Extensions
    # Facade to abstract calls to internal RSpec methods.
    # To allow comparing the monkey patch with the original RSpec code, keep a similar method structure and permalink to the source.
    module RSpecExtension
      Seed = Struct.new(:value, :used?)

      def self.setup!
        RSpec::Core::World.prepend(World)
        RSpec::Core::Runner.prepend(Runner)
        RSpec::Core::Configuration.prepend(Configuration)
      end

      module World
        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/world.rb#L171
        #
        # Filters are not announced because we do not load tests during setup. It would print `No examples found.` and we don't want that.
        def knapsack__announce_filters
          fail_if_config_and_cli_options_invalid
        end
      end

      module Runner
        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L98
        #
        # `@configuration.load_spec_files` is not called because we load tests in batches with `knapsack__load_spec_files_batch` later on.
        def knapsack__setup(stream_error = $stderr, stream_out = $stdout)
          configure(stream_error, stream_out)
        ensure
          world.knapsack__announce_filters
        end

        def knapsack__wants_to_quit?
          world.wants_to_quit
        end

        def knapsack__rspec_is_quitting?
          world.respond_to?(:rspec_is_quitting) && world.rspec_is_quitting
        end

        def knapsack__exit_early
          _exit_status = configuration.reporter.exit_early(exit_code)
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/configuration.rb#L546
        def knapsack__error_exit_code
          configuration.error_exit_code # nil unless `--error-exit-code` is specified
        end

        # must be called after `Runner#knapsack__setup` that loads the `spec_helper.rb` configuration
        def knapsack__deprecated_run_all_when_everything_filtered_enabled?
          configuration.respond_to?(:run_all_when_everything_filtered) && !!configuration.run_all_when_everything_filtered
        end

        def knapsack__seed
          Seed.new(configuration.seed.to_s, configuration.seed_used?)
        end

        # @param test_file_paths Array[String]
        #   Example: ['a_spec.rb', 'b_spec.rb[1:1]']
        def knapsack__load_spec_files_batch(test_file_paths)
          world.reset

          # Reset filters, but do not reset `configuration.static_config_filter_manager` to preserve the --tag option
          filter_manager = RSpec::Core::FilterManager.new
          options.configure_filter_manager(filter_manager)
          configuration.filter_manager = filter_manager

          configuration.knapsack__load_spec_files(test_file_paths)
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L113
        #
        # Ignore `configuration.fail_if_no_examples` in Queue Mode:
        #   * a late CI node, started after all tests were executed by other nodes, is expected to receive an empty batch
        #   * a batch could contain tests with no examples (e.g. commented out)
        #
        # @return [Fixnum] exit status code.
        def knapsack__run_specs(queue_runner)
          # Based on:
          # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/world.rb#L53
          ordering_strategy = configuration.ordering_registry.fetch(:global)
          node_examples_passed = true

          configuration.reporter.report(_expected_example_count = 0) do |reporter|
            configuration.with_suite_hooks do
              queue_runner.with_batch do |test_file_paths, queue|
                knapsack__load_spec_files_batch(test_file_paths)

                examples_passed = ordering_strategy.order(world.example_groups).map do |example_group|
                  queue_runner.handle_signal!
                  example_group.run(reporter)
                end.all?

                if examples_passed
                  queue.mark_batch_passed
                else
                  queue.mark_batch_failed
                  node_examples_passed = false
                end

                knapsack__persist_example_statuses

                if reporter.fail_fast_limit_met?
                  queue_runner.log_fail_fast_limit_met
                  break
                end
              end
            end

            exit_code(node_examples_passed)
          end
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L90
        def knapsack__persist_example_statuses
          persist_example_statuses
        end
      end

      module Configuration
        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/configuration.rb#L1619
        def knapsack__load_spec_files(test_file_paths)
          batch_of_files_to_run = get_files_to_run(test_file_paths)
          batch_of_files_to_run.each do |f|
            file = File.expand_path(f)
            load_file_handling_errors(:load, file)
            loaded_spec_files << file
          end
        end
      end
    end
  end
end
