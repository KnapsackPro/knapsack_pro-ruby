# frozen_string_literal: true

module KnapsackPro
  class TestSuite
    Result = Struct.new(:test_files, :quick?)

    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def calculate_test_files
      return @result if defined?(@result)

      unless adapter_class.split_by_test_cases_enabled?
        return @result = Result.new(all_test_files_to_run, true)
      end

      if KnapsackPro::Config::Env.slow_test_file_pattern
        slow_test_files = KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        return @result = Result.new(all_test_files_to_run, true) if slow_test_files.empty?
      end

      slow_id_paths = adapter_class.calculate_slow_id_paths
      test_files = adapter_class.concat_paths(all_test_files_to_run, slow_id_paths)
      @result = Result.new(test_files, false)
    end

    def all_test_files_to_run
      @all_test_files_to_run ||= KnapsackPro::TestFileFinder.call(TestFilePattern.call(adapter_class))
    end

    private

    attr_reader :adapter_class
  end
end
