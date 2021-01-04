module KnapsackPro
  module TestCaseDetectors
    class RSpecTestExampleDetector
      REPORT_DIR = "#{KnapsackPro::Config::Env::TMP_DIR}/test_case_detectors/rspec"

      def generate_json_report
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

        cli_args = cli_format + [
          '--dry-run',
          '--out', report_path,
          '--default-path', test_dir,
        ] + KnapsackPro::TestFilePresenter.paths(test_file_entities)
        options = ::RSpec::Core::ConfigurationOptions.new(cli_args)
        exit_code = ::RSpec::Core::Runner.new(options).run($stderr, $stdout)
        if exit_code != 0
          debug_cmd = ([
            'bundle exec rspec',
          ] + cli_args).join(' ')

          KnapsackPro.logger.error('-'*10 + ' START of actionable error message ' + '-'*50)
          KnapsackPro.logger.error('There was a problem while generating test examples for the slow test files using the RSpec dry-run flag. To reproduce the error triggered by the RSpec, please try to run below command (this way, you can find out what is causing the error):')
          KnapsackPro.logger.error(debug_cmd)
          KnapsackPro.logger.error('-'*10 + ' END of actionable error message ' + '-'*50)

          raise 'There was a problem while generating test examples for the slow test files. Please read actionable error message above.'
        end
      end

      def test_file_example_paths
        raise "No report found at #{report_path}" unless File.exists?(report_path)

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

      def report_path
        "#{REPORT_DIR}/rspec_dry_run_json_report_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
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
        FileUtils.mkdir_p(REPORT_DIR)
      end

      def remove_old_json_report
        File.delete(report_path) if File.exists?(report_path)
      end

      def test_file_hash_for(test_file_path)
        {
          'path' => TestFileCleaner.clean(test_file_path)
        }
      end
    end
  end
end
