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

    # in fallback mode we always want to run the whole test files
    # (not split by test cases) to guarantee that each test will be executed
    # at least once across parallel CI nodes
    def fallback_mode_test_files
      all_test_files_to_run
    end

    # detect test files present on the disk that should be run
    # this may include some fast test files + slow test files split by test cases
    def fast_and_slow_test_files_to_run
      test_files_to_run = all_test_files_to_run

      if adapter_class == KnapsackPro::Adapters::RSpecAdapter && KnapsackPro::Config::Env.rspec_split_by_test_examples?
        unless Gem::Version.new(::RSpec::Core::Version::STRING) >= Gem::Version.new('3.3.0')
          raise 'RSpec >= 3.3.0 is required to split test files by test examples. Learn more: https://github.com/KnapsackPro/knapsack_pro-ruby#split-test-files-by-test-cases'
        end

        slow_test_files = get_slow_test_files

        KnapsackPro.logger.info("Generating RSpec test examples JSON report for slow test files to prepare it to be split by test examples (by individual 'it's. Thanks to that a single slow test file can be split across parallel CI nodes). Analyzing #{slow_test_files.size} slow test files.")

        # generate RSpec JSON report in separate process to not pollute RSpec state
        cmd = [
          'RACK_ENV=test',
          'RAILS_ENV=test',
          KnapsackPro::Config::Env.rspec_test_example_detector_prefix,
          'rake knapsack_pro:rspec_test_example_detector',
        ].join(' ')
        unless Kernel.system(cmd)
          raise "Could not generate JSON report for RSpec. Rake task failed when running #{cmd}"
        end

        # read JSON report
        detector = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new
        test_file_example_paths = detector.test_file_example_paths

        KnapsackPro::TestFilesWithTestCasesComposer.call(test_files_to_run, slow_test_files, test_file_example_paths)
      else
        test_files_to_run
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

    def all_test_files_to_run
      KnapsackPro::TestFileFinder.call(test_file_pattern)
    end

    def slow_test_file_pattern
      KnapsackPro::Config::Env.slow_test_file_pattern
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
  end
end
