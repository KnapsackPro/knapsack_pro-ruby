# frozen_string_literal: true

module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      def generate_json_report(rspec_args)
        raise "The internal KNAPSACK_PRO_RSPEC_OPTIONS environment variable is unset. Ensure it is not overridden accidentally. Otherwise, please report this as a bug: #{KnapsackPro::Urls::SUPPORT}" if rspec_args.nil?

        require 'rspec/core'

        cli_format =
          if Gem::Version.new(::RSpec::Core::Version::STRING) < Gem::Version.new('3.6.0')
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
          File.write(report_path, no_examples_json)
          return
        end

        args = (rspec_args || '').split
        cli_args_without_formatters = KnapsackPro::Adapters::RSpecAdapter.remove_formatters(args)

        # Apply a --format option which overrides formatters from the RSpec custom option files like `.rspec`.
        cli_args = cli_args_without_formatters + cli_format + [
          '--dry-run',
          '--out', report_path,
          '--default-path', test_dir
        ] + KnapsackPro::TestFilePresenter.paths(test_file_entities)
        exit_code = begin
          options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
          ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
        rescue SystemExit => e
          e.status
        end

        return if exit_code.zero?

        report.fetch('messages', []).each { |message| puts message }
        command = (['bundle exec rspec'] + cli_args).join(' ')
        KnapsackPro.logger.error("Failed to generate the slow test files report: #{command}")
        exit exit_code
      end

      def test_file_example_paths
        raise "No report found at #{report_path}" unless File.exist?(report_path)

        json_report = File.read(report_path)
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

      def report_dir
        "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/test_case_detectors/rspec"
      end

      def report_path
        "#{report_dir}/rspec_dry_run_json_report_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
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

      def test_file_pattern
        KnapsackPro::TestFilePattern.call(adapter_class)
      end

      def ensure_report_dir_exists
        KnapsackPro::Config::TempFiles.ensure_temp_directory_exists!
        FileUtils.mkdir_p(report_dir)
      end

      def remove_old_json_report
        File.delete(report_path) if File.exist?(report_path)
      end

      def test_file_hash_for(test_file_path)
        {
          'path' => TestFileCleaner.clean(test_file_path)
        }
      end
    end
  end
end
