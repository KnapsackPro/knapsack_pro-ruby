# frozen_string_literal: true

module KnapsackPro
  module Formatters
    class TimeTrackerFetcher
      def self.call
        ::RSpec
          .configuration
          .formatters
          .find { |f| f.class.to_s == "KnapsackPro::Formatters::TimeTracker" }
      end

      def self.unexecuted_test_files
        time_tracker = call
        return [] unless time_tracker
        time_tracker.unexecuted_test_files
      end
    end
  end
end
