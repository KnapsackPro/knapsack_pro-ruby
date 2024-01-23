# frozen_string_literal: true

module KnapsackPro
  module Extensions
    module RSpecExtension
      def self.setup!
        RSpec::Core::World.prepend(World)
        RSpec::Core::Runner.prepend(Runner)
        RSpec::Core::Configuration.prepend(Configuration)
      end

      module World
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

        def knapsack__exit_early
          _exit_status = configuration.reporter.exit_early(exit_code)
        end

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
