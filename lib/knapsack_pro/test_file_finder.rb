module KnapsackPro
  class TestFileFinder
    def self.call(test_file_pattern, test_file_list_enabled: true)
      new(test_file_pattern, test_file_list_enabled).call
    end

    # finds slow test files on disk based on ENV patterns
    def self.slow_test_files_by_pattern(adapter_class)
      raise 'KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN not defined' unless KnapsackPro::Config::Env.slow_test_file_pattern

      test_file_pattern = TestFilePattern.call(adapter_class)
      test_file_paths = KnapsackPro::TestFileFinder.call(test_file_pattern)

      slow_test_file_paths = KnapsackPro::TestFileFinder.call(KnapsackPro::Config::Env.slow_test_file_pattern, test_file_list_enabled: false)

      # slow test files (KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN)
      # should be subset of test file pattern (KNAPSACK_PRO_TEST_FILE_PATTERN)
      slow_test_file_paths & test_file_paths
    end

    def initialize(test_file_pattern, test_file_list_enabled)
      @test_file_pattern = test_file_pattern
      @test_file_list_enabled = test_file_list_enabled
    end

    def call
      test_file_hashes = []
      test_files.each do |test_file_path|
        test_file_hashes << test_file_hash_for(test_file_path)
      end
      test_file_hashes
    end

    private

    attr_reader :test_file_pattern, :test_file_list_enabled

    def test_files
      if test_file_list_enabled && KnapsackPro::Config::Env.test_file_list
        return KnapsackPro::Config::Env.test_file_list.split(',').map(&:strip)
      end

      test_file_paths = Dir.glob(test_file_pattern).uniq

      excluded_test_file_paths =
        if KnapsackPro::Config::Env.test_file_exclude_pattern
          Dir.glob(KnapsackPro::Config::Env.test_file_exclude_pattern).uniq
        else
          []
        end

      (test_file_paths - excluded_test_file_paths).sort
    end

    def test_file_hash_for(test_file_path)
      {
        'path' => TestFileCleaner.clean(test_file_path)
      }
    end
  end
end
