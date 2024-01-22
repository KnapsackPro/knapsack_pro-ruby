module KnapsackPro
  module Extensions
    module RSpecExtension
      def self.setup!
        RSpec::Core::World.prepend(World)
        RSpec::Core::Runner.prepend(Runner)
      end

      module World
        def knapsack__setup
          fail_if_config_and_cli_options_invalid
        end
      end

      module Runner
        def knapsack__setup
          # Abstract from RSpec::Core::Runner#setup, since we do not need to set any filters or files at this point,
          # and we do not want to let world.announce_filters to be called, since it will print
          # out `No examples found.` message.
          configure($stderr, $stdout)

          world.knapsack__setup
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
          !!(configuration.respond_to?(:run_all_when_everything_filtered) && configuration.run_all_when_everything_filtered)
        end

        def knapsack__seed
          configuration.seed.to_s
        end

        def knapsack__seed_used?
          configuration.seed_used?
        end
      end
    end
  end
end
