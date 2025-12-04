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

      unless (slow_id_paths = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new.precalculated_slow_id_paths).nil?
        KnapsackPro.logger.info('Using precalculated Split by Test Examples.')
        test_files = adapter_class.concat_paths(all_test_files_to_run, slow_id_paths)
        return @result = Result.new(test_files, true)
      end

      if KnapsackPro::Config::Env.slow_test_file_pattern
        slow_test_files = KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        return @result = Result.new(all_test_files_to_run, true) if slow_test_files.empty?
      end

      slow_id_paths = adapter_class.calculate_slow_id_paths
      test_files = adapter_class.concat_paths(all_test_files_to_run, slow_id_paths)
      @result = Result.new(test_files, false)
    end

    # In Fallback Mode, we always want to run whole test files (not split by
    # test cases) to guarantee that each test will be executed at least once
    # across parallel CI nodes.
    def fallback_test_files
      all_test_files_to_run
    end

    private

    attr_reader :adapter_class

    def all_test_files_to_run
      @all_test_files_to_run ||= KnapsackPro::TestFileFinder.call(TestFilePattern.call(adapter_class))
    end
  end
end
