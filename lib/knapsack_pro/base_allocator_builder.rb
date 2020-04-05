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
      found_test_files = KnapsackPro::TestFileFinder.call(test_file_pattern)

      if adapter_class == KnapsackPro::Adapters::RSpecAdapter && KnapsackPro::Config::Env.rspec_split_by_test_examples?
        test_files_count = found_test_files.size

        KnapsackPro.logger.warn("Generating RSpec test examples JSON report to prepare your test suite to be split by test examples (by individual 'it'. Thanks to that a single test file can be split across parallel CI nodes). Analyzing #{test_files_count} test files.")

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
        detector.test_file_example_paths
      else
        found_test_files
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
  end
end
