module KnapsackPro
  class BaseAllocatorBuilder
    TEST_RUNNER_MAP = {
      KnapsackPro::Adapters::RSpecAdapter => 'rspec',
      KnapsackPro::Adapters::CucumberAdapter => 'cucumber',
      KnapsackPro::Adapters::MinitestAdapter => 'minitest',
      KnapsackPro::Adapters::SpinachAdapter => 'spinach',
      KnapsackPro::Adapters::TestUnitAdapter => 'test-unit',
    }

    def initialize(adapter_class)
      @adapter_class = adapter_class
      ENV['KNAPSACK_PRO_TEST_RUNNER'] = TEST_RUNNER_MAP[adapter_class]
    end

    def allocator
      raise NotImplementedError
    end

    def test_dir
      KnapsackPro::Config::Env.test_dir || TestFilePattern.test_dir(adapter_class)
    end

    def test_files
      test_file_paths = KnapsackPro::TestFileFinder.call(test_file_pattern)

      if adapter_class == KnapsackPro::Adapters::RSpecAdapter && KnapsackPro::Config::Env.rspec_split_by_test_examples?
        if slow_test_file_pattern
          slow_test_file_paths = KnapsackPro::TestFileFinder.call(slow_test_file_pattern, test_file_list_enabled: false)
          test_files_count = slow_test_file_paths.size
        else
          test_files_count = test_file_paths.size
        end

        KnapsackPro.logger.warn("Generating RSpec test examples JSON report to prepare your test suite to be split by test examples (by individual 'it's. Thanks to that a single test file can be split across parallel CI nodes). Analyzing #{test_files_count} test files.")

        if test_files_count > 1000
          KnapsackPro.logger.warn("You have more than 1000 test files, it may take longer to generate test examples. Please wait...")
        end

        # generate RSpec JSON report in separate process to not pollute RSpec state
        cmd = 'bundle exec rake knapsack_pro:rspec_test_example_detector'
        unless Kernel.system(cmd)
          raise "Could not generate JSON report for RSpec. Rake task failed when running #{cmd}"
        end

        # read JSON report
        detector = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new
        test_file_example_paths = detector.test_file_example_paths

        if slow_test_file_pattern
          slow_paths = slow_test_file_paths.map { |t| t.fetch('path') }

          test_file_paths_without_slow_test_file_paths = test_file_paths.reject do |t|
            slow_paths.include?(t.fetch('path'))
          end

          test_file_paths_without_slow_test_file_paths + test_file_example_paths
        else
          test_file_example_paths
        end
      else
        test_file_paths
      end
    end

    private

    attr_reader :adapter_class

    def env
      KnapsackPro::Config::Env
    end

    def repository_adapter
      KnapsackPro::RepositoryAdapterInitiator.call
    end

    def test_file_pattern
      TestFilePattern.call(adapter_class)
    end

    def slow_test_file_pattern
      KnapsackPro::Config::Env.slow_test_file_pattern
    end
  end
end
