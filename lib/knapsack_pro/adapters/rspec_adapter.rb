# frozen_string_literal: true

require_relative '../formatters/time_tracker_fetcher'

module KnapsackPro
  module Adapters
    class RSpecAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'spec/**{,/*/**}/*_spec.rb'
      # https://github.com/rspec/rspec/blob/86b5e4218eece4c1913fe9aad24c0a96d8bc9f40/rspec-core/lib/rspec/core/example.rb#L122
      REGEX = /\A(.*?)(?:\[([\d\s:,]+)\])?\z/.freeze

      def self.split_by_test_cases_enabled?
        return false unless KnapsackPro::Config::Env.rspec_split_by_test_examples?

        require 'rspec/core/version'
        unless Gem::Version.new(::RSpec::Core::Version::STRING) >= Gem::Version.new('3.3.0')
          raise "RSpec >= 3.3.0 is required to split test files by test examples. Learn more: #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}"
        end

        true
      end

      def self.test_file_cases_for(slow_test_files)
        KnapsackPro.logger.info("Generating RSpec test examples JSON report for slow test files to prepare it to be split by test examples (by individual test cases). Thanks to that, a single slow test file can be split across parallel CI nodes. Analyzing #{slow_test_files.size} slow test files.")

        # generate the RSpec JSON report in a separate process to not pollute the RSpec state
        cmd = [
          'RACK_ENV=test',
          'RAILS_ENV=test',
          KnapsackPro::Config::Env.rspec_test_example_detector_prefix,
          'rake knapsack_pro:rspec_test_example_detector',
        ].join(' ')
        unless Kernel.system(cmd)
          raise "Could not generate JSON report for RSpec. Rake task failed when running #{cmd}"
        end

        # read the JSON report
        KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new.test_file_example_paths
      end

      def self.has_format_option?(cli_args)
        !!parsed_options(cli_args)&.[](:formatters)
      end

      def self.has_require_rails_helper_option?(cli_args)
        (parsed_options(cli_args)&.[](:requires) || []).include?("rails_helper")
      end

      def self.order_option(cli_args)
        parsed_options(cli_args)&.[](:order)
      end

      def self.remove_formatters(cli_args)
        formatter_options = ['-f', '--format', '-o', '--out']
        cli_args.dup.each_with_index do |arg, index|
          if formatter_options.include?(arg)
            cli_args[index] = nil
            cli_args[index + 1] = nil
          end
        end
        cli_args.compact
      end

      def self.file_path_for(example)
        [
          -> { parse_file_path(example.id) },
          -> { example.metadata[:file_path] },
          -> { example.metadata[:example_group][:file_path] },
          -> { top_level_group(example)[:file_path] },
        ]
          .each do |path|
            p = path.call
            return p if p.include?('_spec.rb') || p.include?('.feature')
          end

        return ''
      end

      def self.parse_file_path(path)
        file, _id = path.match(REGEX).captures
        file
      end

      def self.id_path?(path)
        _file, id = path.match(REGEX).captures
        !id.nil?
      end

      def self.rails_helper_exists?(test_dir)
        File.exist?("#{test_dir}/rails_helper.rb")
      end

      # private
      def self.top_level_group(example)
        group = example.metadata[:example_group]
        until group[:parent_example_group].nil?
          group = group[:parent_example_group]
        end
        group
      end

      def bind_time_tracker
        ensure_no_focus!
        bind_regular_mode_time_tracker
        log_tests_duration
      end

      def ensure_no_focus!
        ::RSpec.configure do |config|
          config.around(:each) do |example|
            if example.metadata[:focus] && KnapsackPro::Adapters::RSpecAdapter.rspec_configuration.filter.rules[:focus]
              file_path = KnapsackPro::Adapters::RSpecAdapter.file_path_for(example)
              file_path = KnapsackPro::TestFileCleaner.clean(file_path)

              raise "Knapsack Pro found an example tagged with focus in #{file_path}, please remove it. See more: #{KnapsackPro::Urls::RSPEC__SKIPS_TESTS}"
            end

            example.run
          end
        end
      end

      def log_tests_duration
        ::RSpec.configure do |config|
          config.append_after(:suite) do
            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            formatted = KnapsackPro::Presenter.global_time(time_tracker.duration)
            KnapsackPro.logger.debug(formatted)
          end
        end
      end

      def bind_regular_mode_time_tracker
        return unless KnapsackPro::Config::Env.regular_mode?

        ::RSpec.configure do |config|
          config.append_before(:suite) do
            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            time_tracker.scheduled_paths = KnapsackPro::Adapters::RSpecAdapter.scheduled_paths
          end
        end
      end

      def bind_save_report
        ::RSpec.configure do |config|
          config.after(:suite) do
            time_tracker = KnapsackPro::Formatters::TimeTrackerFetcher.call
            KnapsackPro::Report.save(time_tracker.batch)
          end
        end
      end

      def bind_before_queue_hook
        ::RSpec.configure do |config|
          config.before(:suite) do
            KnapsackPro::Hooks::Queue.call_before_queue
          end
        end
      end

      def bind_after_queue_hook
        ::RSpec.configure do |config|
          config.after(:suite) do
            KnapsackPro::Hooks::Queue.call_after_queue
          end
        end
      end

      private

      # Hide RSpec configuration so that we could mock it in the spec.
      # Mocking existing RSpec configuration could impact test's runtime.
      def self.rspec_configuration
        ::RSpec.configuration
      end

      def self.scheduled_paths
        rspec_configuration.instance_variable_get(:@files_or_directories_to_run) || []
      end

      def self.parsed_options(cli_args)
        ::RSpec::Core::Parser.parse(cli_args)
      rescue SystemExit
        nil
      end
    end

    # This is added to provide backwards compatibility
    # In case someone is doing switch from knapsack gem to the knapsack_pro gem
    # and didn't notice the class name changed
    class RspecAdapter < RSpecAdapter
      def self.bind
        error_message = "You have attempted to call KnapsackPro::Adapters::RspecAdapter.bind. Please switch to using the new class name: KnapsackPro::Adapters::RSpecAdapter. See #{KnapsackPro::Urls::INSTALLATION_GUIDE} for up-to-date configuration instructions."
        KnapsackPro.logger.error(error_message)
        raise error_message
      end
    end
  end
end
