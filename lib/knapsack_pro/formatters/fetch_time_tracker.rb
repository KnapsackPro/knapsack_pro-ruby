module KnapsackPro
  module Formatters
    class TimeTrackerFetcher
      def self.call
        ::RSpec
          .configuration
          .formatters
          .find { |f| f.class.to_s == "KnapsackPro::Formatters::TimeTracker" }
      end
    end
  end
end
