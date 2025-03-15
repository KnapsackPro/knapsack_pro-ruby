# frozen_string_literal: true

module KnapsackPro
  class TestSuiteBuilder
    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    # Detect test files present on the disk that should be run.
    # This may include fast test files + slow test files split by test cases.
    def fast_and_slow_test_files_to_run
      @fast_and_slow_test_files_to_run ||=
        begin
          if adapter_class.split_by_test_cases_enabled?
            slow_test_files = get_slow_test_files
            if slow_test_files.empty?
              all_test_files_to_run
            else
              test_file_cases = adapter_class.test_file_cases_for(slow_test_files)

              KnapsackPro::TestFilesWithTestCasesComposer.call(all_test_files_to_run, slow_test_files, test_file_cases)
            end
          else
            all_test_files_to_run
          end
        end
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


    def get_slow_test_files
      slow_test_files =
        if slow_test_file_pattern
          KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        else
          # get slow test files from API and ensure they exist on disk
          KnapsackPro::SlowTestFileFinder.call(adapter_class)
        end
      KnapsackPro.logger.debug("Detected #{slow_test_files.size} slow test files: #{slow_test_files.inspect}")
      slow_test_files
    end

    def slow_test_file_pattern
      KnapsackPro::Config::Env.slow_test_file_pattern
    end
  end
end
