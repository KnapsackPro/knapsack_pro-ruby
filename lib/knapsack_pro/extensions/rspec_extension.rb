module KnapsackPro
  module Extensions
    module RSpecExtension
      def self.setup!
        RSpec::Core::World.prepend(World)
        RSpec::Core::Runner.prepend(Runner)
      end

      module World
        def knapsack_setup
          fail_if_config_and_cli_options_invalid
        end
      end

      module Runner
        def knapsack_setup
          # Abstract from RSpec::Core::Runner#setup, since we do not need to set any filters or files at this point,
          # and we do not want to let world.announce_filters to be called, since it will print
          # out `No examples found.` message.
          configure($stderr, $stdout)

          world.knapsack_setup
        end
      end
    end
  end
end
