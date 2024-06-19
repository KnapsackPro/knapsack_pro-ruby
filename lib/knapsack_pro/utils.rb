# frozen_string_literal: true

module KnapsackPro
  class Utils
    def self.unsymbolize(obj)
      JSON.parse(obj.to_json)
    end

    def self.time_now
      if defined?(Timecop) && Process.respond_to?(:clock_gettime_without_mock)
        Process.clock_gettime_without_mock(Process::CLOCK_MONOTONIC)
      else
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
