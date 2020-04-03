module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      REPORT_DIR = 'tmp/knapsack_pro/test_case_detectors/rspec'
      REPORT_PATH = "#{REPORT_DIR}/rspec_dry_run_json_report.json"

      def generate_json_report
        require 'rspec/core'

        ensure_report_dir_exists
        remove_old_json_report

        test_file_paths = KnapsackPro::TestFileFinder.call(test_file_pattern)

        cli_args = [
          '--dry-run',
          '--format', 'json',
          '--out', REPORT_PATH,
          '--default-path', test_dir,
        ] + test_file_paths.map { |t| t.fetch('path') }
        options = RSpec::Core::ConfigurationOptions.new(cli_args)
        exit_code = RSpec::Core::Runner.new(options).run($stderr, $stdout)
        if exit_code != 0
          raise 'There was problem to generate test examples for test suite'
        end
      end

      def test_file_example_paths
        raise "No report found at #{REPORT_PATH}" unless File.exists?(REPORT_PATH)

        json_report = File.read(REPORT_PATH)
        hash_report = JSON.parse(json_report)
        hash_report
          .fetch('examples')
          .map { |e| e.fetch('id') }
          .map { |path| TestFileCleaner.clean(path) }
      end

      private

      def adapter_class
        KnapsackPro::Adapters::RSpecAdapter
      end

      def test_dir
        KnapsackPro::Config::Env.test_dir || TestFilePattern.test_dir(adapter_class)
      end

      def test_file_pattern
        TestFilePattern.call(adapter_class)
      end

      def ensure_report_dir_exists
        FileUtils.mkdir_p(REPORT_DIR)
      end

      def remove_old_json_report
        File.delete(REPORT_PATH) if File.exists?(REPORT_PATH)
      end
    end
  end
end
