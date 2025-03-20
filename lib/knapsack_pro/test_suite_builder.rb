# frozen_string_literal: true

module KnapsackPro
  class TestSuiteBuilder
    Result = Struct.new(:tests_to_run, :tests_found_quickly?)

    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    # Detect test files present on the disk that should be run.
    # This may include fast test files + slow test files split by test cases.
    def call
      return @result if defined?(@result)

      tests_found_quickly = true

      unless adapter_class.split_by_test_cases_enabled?
        return @result = Result.new(all_test_files_to_run, tests_found_quickly)
      end

      slow_test_files =
        if slow_test_file_pattern
          KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        else
          tests_found_quickly = false
          # get slow test files from API and ensure they exist on disk
          KnapsackPro::SlowTestFileFinder.call(adapter_class)
        end

      KnapsackPro.logger.debug("Detected #{slow_test_files.size} slow test files: #{slow_test_files.inspect}")

      if slow_test_files.empty?
        return @result = Result.new(all_test_files_to_run, tests_found_quickly)
      end

      tests_found_quickly = false
      test_file_cases = adapter_class.test_file_cases_for(slow_test_files)

      fast_files_and_cases_for_slow_tests = KnapsackPro::TestFilesWithTestCasesComposer.call(all_test_files_to_run, slow_test_files, test_file_cases)

      @result = Result.new(fast_files_and_cases_for_slow_tests, tests_found_quickly)
    end

    # In Fallback Mode, we always want to run whole test files (not split by
    # test cases) to guarantee that each test will be executed at least once
    # across parallel CI nodes.
    def fallback_mode_test_files
      all_test_files_to_run
    end

    private

    attr_reader :adapter_class

    def all_test_files_to_run
      @all_test_files_to_run ||= KnapsackPro::TestFileFinder.call(test_file_pattern)
    end

    def test_file_pattern
      TestFilePattern.call(adapter_class)
    end

    def slow_test_file_pattern
      KnapsackPro::Config::Env.slow_test_file_pattern
    end
  end
end
