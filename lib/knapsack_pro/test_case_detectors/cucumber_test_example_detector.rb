# frozen_string_literal: true

require 'shellwords'

module KnapsackPro
  module TestCaseDetectors
    class CucumberTestExampleDetector
      def dry_run_to_file(cucumber_args)
        KnapsackPro::Config::TempFiles.ensure_temp_directory_exists!
        FileUtils.mkdir_p(File.dirname(report_path))
        File.delete(report_path) if File.exist?(report_path)

        slow_test_files = fetch_slow_file_paths
        return File.write(report_path, [].to_json) if slow_test_files.empty?

        KnapsackPro.logger.info("Calculating Split by Test Examples. Analyzing #{slow_test_files.size} slow test files.")
        # Shellwords to respect quoted args like --tags "not @slow"
        args = Shellwords.split(cucumber_args || '')
        cli_args_without_formatters = KnapsackPro::Adapters::CucumberAdapter.remove_formatters(args)
        cli_args = cli_args_without_formatters + [
          '--dry-run',
          '--format', 'json',
          '--out', report_path,
          '--require', test_dir,
        ] + KnapsackPro::TestFilePresenter.paths(slow_test_files)
        # Cucumber's option parser mutates the args array, so build the debug command upfront.
        command = (['bundle exec cucumber'] + cli_args).join(' ')
        exit_code = dry_run(cli_args)
        return if exit_code.zero?

        KnapsackPro.logger.error("Failed to calculate Split by Test Examples: #{command}")
        exit exit_code
      end

      def slow_id_paths!
        raise "No report found at #{report_path}" unless File.exist?(report_path)

        JSON.parse(File.read(report_path))
          .flat_map { |feature| feature.fetch('elements', []).map { |element| [feature, element] } }
          .select { |_feature, element| element['type'] == 'scenario' }
          .map { |feature, element| TestFileCleaner.clean("#{feature.fetch('uri')}:#{element.fetch('line')}") }
      end

      private

      def dry_run(cli_args)
        require 'cucumber'

        ::Cucumber::Cli::Main.new(cli_args).execute!
        0
      rescue SystemExit => e
        e.status
      end

      def report_path
        "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/test_case_detectors/cucumber/cucumber_dry_run_json_report_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
      end

      def fetch_slow_file_paths
        if KnapsackPro::Config::Env.slow_test_file_pattern
          return KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
        end

        if KnapsackPro::Config::Env.test_files_encrypted?
          raise "Split by test cases is not possible when you have enabled test file names encryption ( #{KnapsackPro::Urls::ENCRYPTION} ). You need to disable encryption with KNAPSACK_PRO_TEST_FILES_ENCRYPTED=false in order to use split by test cases #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}"
        end

        build_distribution = KnapsackPro::BuildDistributionFetcher.new.call
        merged_test_files_from_api = KnapsackPro::TestCaseMergers::CucumberMerger.new(build_distribution.test_files).call
        test_files_existing_on_disk = KnapsackPro::TestFileFinder.select_test_files_that_can_be_run(adapter_class, merged_test_files_from_api)
        KnapsackPro::SlowTestFileDeterminer.call(test_files_existing_on_disk)
      end

      def adapter_class
        KnapsackPro::Adapters::CucumberAdapter
      end

      def test_dir
        KnapsackPro::Config::Env.test_dir || KnapsackPro::TestFilePattern.test_dir(adapter_class)
      end
    end
  end
end
