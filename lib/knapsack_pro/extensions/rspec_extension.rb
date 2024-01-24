# frozen_string_literal: true

module KnapsackPro
  module Extensions
    # Knapsack extension on top of RSpec methods.
    #
    # It should expose methods with the `knapsack__` prefix.
    # The methods should hide RSpec public or private methods, a complex chain of methods, etc.
    # From an outside perspective, when someone uses the `knapsack__` method, they don't break the Law of Demeter.
    # All the complexity of RSpec internals is hidden inside of the `knapsack__` method.
    #
    # The structure of the `knapsack__` method that is inspired by an existing RSpec method should have a similar structure to the original method.
    # It should be easy to see a code difference when a new RSpec version is released.
    # Please use permalinks to RSpec source code when you create a new `knapsack__` method.
    module RSpecExtension
      def self.setup!
        RSpec::Core::World.prepend(World)
        RSpec::Core::Runner.prepend(Runner)
        RSpec::Core::Configuration.prepend(Configuration)
      end

      module World
        # Based on `announce_filters`
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/world.rb#L171
        def knapsack__setup
          fail_if_config_and_cli_options_invalid
        end
      end

      module Runner
        def knapsack__mark_setup_as_done
          @knapsack__setup_done = true
        end

        def knapsack__setup_done?
          !!@knapsack__setup_done
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/runner.rb#L98
        def knapsack__setup
          # Abstract from RSpec::Core::Runner#setup, since we do not need to set any filters or files at this point,
          # and we do not want to let world.announce_filters to be called, since it will print
          # out `No examples found.` message.
          configure($stderr, $stdout)

          world.knapsack__setup

          knapsack__mark_setup_as_done
        end

        def knapsack__wants_to_quit?
          world.wants_to_quit
        end

        # `rspec_is_quitting` was added in RSpec 3.11.0
        # Changelog:
        #   https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/Changelog.md#3110--2022-02-09
        # PR:
        #   https://github.com/rspec/rspec-core/pull/2926
        # We support RSpec < 3.11.0.
        def knapsack__rspec_is_quitting?
          world.respond_to?(:rspec_is_quitting) && world.rspec_is_quitting
        end

        def knapsack__exit_early
          _exit_status = configuration.reporter.exit_early(exit_code)
        end

        # Based on:
        # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/configuration.rb#L546
        # Set with --error-exit-code CODE - Override the exit code used when there are errors loading or running specs outside of examples.
        def knapsack__error_exit_code
          _default = nil || configuration.error_exit_code
        end

        def knapsack__deprecated_run_all_when_everything_filtered_enabled?
          raise "Cannot call the #{__method__} method because setup was not done." unless knapsack__setup_done?

          !!(configuration.respond_to?(:run_all_when_everything_filtered) && configuration.run_all_when_everything_filtered)
        end

        def knapsack__seed
          configuration.seed.to_s
        end

        def knapsack__seed_used?
          configuration.seed_used?
        end

        # @param test_file_paths Array[String]
        #   Examples:
        #     a_spec.rb
        #     a_spec.rb[1:1]
        def knapsack__load_spec_files_batch(test_file_paths)
          world.reset

          # Reset filters
          # but we do not reset `configuration.static_config_filter_manager` to preserve the --tag option
          filter_manager = RSpec::Core::FilterManager.new
          options.configure_filter_manager(filter_manager)
          configuration.filter_manager = filter_manager

          configuration.knapsack__load_spec_files(test_file_paths)
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
        def run_specs(queue_runner)
          # Based on:
          # https://github.com/rspec/rspec-core/blob/f8c8880dabd8f0544a6f91d8d4c857c1bd8df903/lib/rspec/core/world.rb#L53
          ordering_strategy = configuration.ordering_registry.fetch(:global)
          node_examples_passed = true

          configuration.with_suite_hooks do
            exit_status = configuration.reporter.report(_expected_example_count = 0) do |reporter|
              queue_runner.with_batched_tests_from_queue do |test_file_paths|
                knapsack__load_spec_files_batch(test_file_paths)

                examples_passed = ordering_strategy.order(world.example_groups).map do |example_group|
                  queue_runner.handle_signal!
                  example_group.run(reporter)
                end.all?

                node_examples_passed = false unless examples_passed

                if reporter.fail_fast_limit_met?
                  queue_runner.log_fail_fast_limit_met
                  break
                end
              end
            end

            exit_code(node_examples_passed)
          end
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
