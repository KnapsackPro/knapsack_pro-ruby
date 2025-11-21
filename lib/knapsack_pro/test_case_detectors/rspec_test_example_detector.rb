# frozen_string_literal: true

module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      def calculate(rspec_args)
        KnapsackPro::Config::TempFiles.ensure_temp_directory_exists!
        FileUtils.mkdir_p(File.dirname(report_path))
        File.delete(report_path) if File.exist?(report_path)
        return File.write(report_path, { examples: [] }.to_json) if slow_test_files.empty?

        KnapsackPro.logger.info("Calculating Split by Test Examples. Analyzing #{slow_test_files.size} slow test files.")
        args = (rspec_args || '').split
        cli_args_without_formatters = KnapsackPro::Adapters::RSpecAdapter.remove_formatters(args)
        cli_args = cli_args_without_formatters + cli_format + [
          '--dry-run',
          '--out', report_path,
          '--default-path', test_dir
        ] + KnapsackPro::TestFilePresenter.paths(slow_test_files)
        exit_code = dry_run(cli_args)
        return if exit_code.zero?

        report.fetch('messages', []).each { |message| puts message }
        command = (['bundle exec rspec'] + cli_args).join(' ')
        KnapsackPro.logger.error("Failed to calculate Split by Test Examples: #{command}")
        exit exit_code
      end

      # Apply a --format option which overrides formatters from the RSpec custom option files like `.rspec`.
      def cli_format
        require 'rspec/core'

        if Gem::Version.new(::RSpec::Core::Version::STRING) < Gem::Version.new('3.6.0')
          require_relative '../formatters/rspec_json_formatter'
          ['--format', KnapsackPro::Formatters::RSpecJsonFormatter.to_s]
        else
          ['--format', 'json']
        end
      end

      def dry_run(cli_args)
        require 'rspec/core'

        options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
        ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
      rescue SystemExit => e
        e.status
      end

      def slow_id_paths!
        raise "No report found at #{report_path}" unless File.exist?(report_path)

        JSON.parse(File.read(report_path))
          .fetch('examples')
          .map { |example| TestFileCleaner.clean(example.fetch('id')) }
      end

      def precalculated_slow_id_paths
        return nil if ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES_FILE'].nil?

        slow_id_paths!
      end

      def report_path
        ENV['KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES_FILE'] ||
          "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/test_case_detectors/rspec/rspec_dry_run_json_report_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
      end

      private

      def slow_test_files
        @slow_test_files ||=
          if KnapsackPro::Config::Env.slow_test_file_pattern
            KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
          else
            KnapsackPro::SlowTestFileFinder.call(adapter_class)
          end
      end

      def report
        return {} unless File.exist?(report_path)

        JSON.parse(File.read(report_path))
      end

      def adapter_class
        KnapsackPro::Adapters::RSpecAdapter
      end

      def test_dir
        KnapsackPro::Config::Env.test_dir || KnapsackPro::TestFilePattern.test_dir(adapter_class)
      end
    end
  end
end
