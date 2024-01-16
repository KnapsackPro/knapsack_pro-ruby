module KnapsackPro
  module Extensions
    module RSpecExtension
      def self.setup!
        RSpec::Core::Runner.prepend(Runner)
      end

      module Runner
        def knapsack
          'knapsack'
        end
      end
    end
  end
end
