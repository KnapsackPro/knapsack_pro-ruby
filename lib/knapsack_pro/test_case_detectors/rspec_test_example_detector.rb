# frozen_string_literal: true

module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      def dry_run_to_file(rspec_args, slow_test_files = slow_test_files(KnapsackPro::BuildDistributionFetcher.new))
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

      def calculate_slow_id_paths(rspec_args)
        result = fetch_slow_file_paths(KnapsackPro::OptimizedBuildDistributionFetcher.new)
        return { test_queue_url: result.fetch(:test_queue_url), slow_id_paths: [] } unless result.fetch(:test_queue_url).nil?

        dry_run_to_file(rspec_args, result.fetch(:slow_file_paths))
        { test_queue_url: nil, slow_id_paths: slow_id_paths! }
      end

      def slow_id_paths!
        raise "No report found at #{report_path}" unless File.exist?(report_path)

        JSON.parse(File.read(report_path))
          .fetch('examples')
          .map { |example| TestFileCleaner.clean(example.fetch('id')) }
      end

      private

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

      def report_path
        "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/test_case_detectors/rspec/rspec_dry_run_json_report_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
      end

      def slow_test_files(build_distribution_fetcher)
        fetch_slow_file_paths(build_distribution_fetcher).fetch(:slow_file_paths)
      end

      def fetch_slow_file_paths(build_distribution_fetcher)
        if KnapsackPro::Config::Env.slow_test_file_pattern
          slow_file_paths = KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
          { test_queue_url: nil, slow_file_paths: slow_file_paths }
        else
          determine_slow_file_paths(build_distribution_fetcher)
        end
      end

      def determine_slow_file_paths(build_distribution_fetcher)
        if KnapsackPro::Config::Env.test_files_encrypted?
          raise "Split by test cases is not possible when you have enabled test file names encryption ( #{KnapsackPro::Urls::ENCRYPTION} ). You need to disable encryption with KNAPSACK_PRO_TEST_FILES_ENCRYPTED=false in order to use split by test cases #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}"
        end

        build_distribution = build_distribution_fetcher.call
        return { test_queue_url: nil, slow_file_paths: [] } if build_distribution.test_queue_url.nil?

        merged_test_files_from_api = KnapsackPro::TestCaseMergers::RSpecMerger.new(build_distribution.test_files).call
        test_files_existing_on_disk = KnapsackPro::TestFileFinder.select_test_files_that_can_be_run(KnapsackPro::Adapters::RSpecAdapter, merged_test_files_from_api)
        slow_file_paths = KnapsackPro::SlowTestFileDeterminer.call(test_files_existing_on_disk)
        { test_queue_url: nil, slow_file_paths: slow_file_paths }
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
