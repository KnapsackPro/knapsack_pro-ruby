# frozen_string_literal: true

module KnapsackPro
  class TestFileFinder
    def self.call(test_file_pattern, test_file_list_enabled: true)
      new(test_file_pattern, test_file_list_enabled).call
    end

    # finds slow test files on disk based on ENV patterns
    # returns example: [{ 'path' => 'a_spec.rb' }]
    def self.slow_test_files_by_pattern(adapter_class)
      raise 'KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN is not defined' unless KnapsackPro::Config::Env.slow_test_file_pattern

      test_file_pattern = KnapsackPro::TestFilePattern.call(adapter_class)
      test_file_entities = call(test_file_pattern)

      slow_test_file_entities = call(KnapsackPro::Config::Env.slow_test_file_pattern, test_file_list_enabled: false)

      # slow test files (KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN)
      # should be subset of test file pattern (KNAPSACK_PRO_TEST_FILE_PATTERN)
      slow_test_file_entities & test_file_entities
    end

    def self.select_test_files_that_can_be_run(adapter_class, candidate_test_files)
      test_file_pattern = KnapsackPro::TestFilePattern.call(adapter_class)
      scheduled_test_files = call(test_file_pattern)
      scheduled_paths = KnapsackPro::TestFilePresenter.paths(scheduled_test_files)
      candidate_paths = KnapsackPro::TestFilePresenter.paths(candidate_test_files)
      intersection = scheduled_paths & candidate_paths
      KnapsackPro::TestFilePresenter.test_files(intersection)
    end

    def initialize(test_file_pattern, test_file_list_enabled)
      @test_file_pattern = test_file_pattern
      @test_file_list_enabled = test_file_list_enabled
    end

    def call
      file_paths.map do |file_path|
        { 'path' => TestFileCleaner.clean(file_path) }
      end
    end

    private

    attr_reader :test_file_pattern, :test_file_list_enabled

    def file_paths
      if test_file_list_enabled && KnapsackPro::Config::Env.test_file_list
        return KnapsackPro::Config::Env.test_file_list.split(',').map(&:strip)
      end

      if test_file_list_enabled && KnapsackPro::Config::Env.test_file_list_source_file
        return File.read(KnapsackPro::Config::Env.test_file_list_source_file).split(/\n/)
      end

      included_paths = Dir.glob(test_file_pattern).uniq

      excluded_paths =
        if KnapsackPro::Config::Env.test_file_exclude_pattern
          Dir.glob(KnapsackPro::Config::Env.test_file_exclude_pattern).uniq
        else
          []
        end

      (included_paths - excluded_paths).sort
    end
  end
end
