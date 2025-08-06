require 'knapsack_pro'
require_relative '../lib/knapsack_pro/formatters/time_tracker'

class TestableTimeTracker < KnapsackPro::Formatters::TimeTracker
  ::RSpec::Core::Formatters.register self, :dump_summary

  if ENV['TEST__SBTE']
    def rspec_split_by_test_example?(_file)
      true
    end
  end

  if ENV['TEST__EMPTY_FILE_PATH']
    def file_path_for(_example)
      ''
    end
  end

  def dump_summary(_)
    method = ENV['TEST__METHOD']
    result = send(method)
    puts Marshal.dump(result)
    return if ENV['TEST__DEBUG'].nil?

    warn 'DEBUG'
    warn result
    warn 'GUBED'
  end
end
