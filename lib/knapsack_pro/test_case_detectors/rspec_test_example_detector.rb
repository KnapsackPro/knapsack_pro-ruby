module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      REPORT_DIR = 'tmp/knapsack_pro/test_case_detectors/rspec'
      REPORT_PATH = "#{REPORT_DIR}/rspec_dry_run_json_report.json"

      def generate_json_report
        require 'rspec/core'

        cli_format =
          if Gem::Version.new(RSpec::Core::Version::STRING) < Gem::Version.new('3.6.0')
            require_relative '../formatters/rspec_json_formatter'
            ['--format', KnapsackPro::Formatters::RSpecJsonFormatter.to_s]
          else
            ['--format', 'json']
          end

        ensure_report_dir_exists
        remove_old_json_report

        test_file_entities = slow_test_files

        if test_file_entities.empty?
          no_examples_json = { examples: [] }.to_json
          File.write(REPORT_PATH, no_examples_json)
          return
        end

        cli_args = cli_format + [
          '--dry-run',
          '--out', REPORT_PATH,
          '--default-path', test_dir,
        ] + KnapsackPro::TestFilePresenter.paths(test_file_entities)
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
          .map { |path_with_example_id| test_file_hash_for(path_with_example_id) }
      end

      def slow_test_files
        if KnapsackPro::Config::Env.slow_test_file_pattern
          KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        else
          # read slow test files from JSON file on disk that was generated
          # by lib/knapsack_pro/base_allocator_builder.rb
          KnapsackPro::SlowTestFileDeterminer.read_from_json_report
        end
      end

      private

      def adapter_class
        KnapsackPro::Adapters::RSpecAdapter
      end

      def test_dir
        KnapsackPro::Config::Env.test_dir || KnapsackPro::TestFilePattern.test_dir(adapter_class)
      end

      def test_file_pattern
        KnapsackPro::TestFilePattern.call(adapter_class)
      end

      def ensure_report_dir_exists
        FileUtils.mkdir_p(REPORT_DIR)
      end

      def remove_old_json_report
        File.delete(REPORT_PATH) if File.exists?(REPORT_PATH)
      end

      def test_file_hash_for(test_file_path)
        {
          'path' => TestFileCleaner.clean(test_file_path)
        }
      end
    end
  end
end
