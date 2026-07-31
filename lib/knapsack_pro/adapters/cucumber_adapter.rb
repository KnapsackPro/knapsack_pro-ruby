# frozen_string_literal: true

module KnapsackPro
  module Adapters
    class CucumberAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'features/**{,/*/**}/*.feature'
      # Matches a test example path like features/a.feature:12
      REGEX = /\A(.*?)(?::(\d+))?\z/.freeze

      def self.split_by_test_cases_enabled?
        return false unless KnapsackPro::Config::Env.cucumber_split_by_test_examples?

        require 'cucumber/platform'
        unless ::Cucumber::VERSION.to_i >= 4
          raise "Cucumber >= 4.0 is required to split test files by test examples. Learn more: #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}"
        end

        true
      end

      def self.calculate_slow_id_paths
        # Shell out not to pollute the Cucumber state
        cmd = [
          'RACK_ENV=test',
          'RAILS_ENV=test',
          KnapsackPro::Config::Env.cucumber_test_example_detector_prefix,
          'rake knapsack_pro:cucumber_test_example_detector',
        ].join(' ')
        raise "Failed to calculate Split by Test Examples: #{cmd}" unless Kernel.system(cmd)

        KnapsackPro::TestCaseDetectors::CucumberTestExampleDetector.new.slow_id_paths!
      end

      def self.parse_file_path(path)
        file, _id = path.match(REGEX).captures
        file
      end

      def self.id_path?(path)
        _file, id = path.match(REGEX).captures
        !id.nil?
      end

      def self.concat_test_files(test_files, id_paths)
        paths = concat_paths(test_files, id_paths)
        KnapsackPro::TestFilePresenter.test_files(paths)
      end

      def self.concat_paths(test_files, id_paths)
        paths = KnapsackPro::TestFilePresenter.paths(test_files)
        file_paths = id_paths.map { |id_path| parse_file_path(id_path) }
        paths + id_paths - file_paths
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

      # When the test file was split by test examples, track the time execution
      # per test example path (e.g., features/a.feature:12).
      # Otherwise, track the time execution per test file path.
      def self.tracked_test_path(object)
        file = test_path(object)
        return file unless split_by_test_cases_enabled?

        id_path = "#{file}:#{object.location.line}"
        KnapsackPro.tracker.scheduled_test_path?(id_path) ? id_path : file
      end

      def self.test_path(object)
        if ::Cucumber::VERSION.to_i >= 2
          test_case = object
          test_case.location.file
        else
          if object.respond_to?(:scenario_outline)
            if object.scenario_outline.respond_to?(:feature)
              # Cucumber < 1.3
              object.scenario_outline.feature.file
            else
              # Cucumber >= 1.3
              object.scenario_outline.file
            end
          else
            if object.respond_to?(:feature)
              # Cucumber < 1.3
              object.feature.file
            else
              # Cucumber >= 1.3
              object.file
            end
          end
        end
      end

      def bind_time_tracker
        Around do |object, block|
          KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::CucumberAdapter.tracked_test_path(object)
          KnapsackPro.tracker.start_timer
          block.call
          KnapsackPro.tracker.stop_timer
        end

        ::Kernel.at_exit do
          KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report(latest_error = nil)
        ::Kernel.at_exit do
          # $! is latest error message
          latest_error = (latest_error || $!)
          exit_status = latest_error.status if latest_error.is_a?(SystemExit)
          # saving report makes API call which changes exit status
          # from cucumber so we need to preserve cucumber exit status
          KnapsackPro::Report.save
          ::Kernel.exit exit_status if exit_status
        end
      end

      def bind_before_queue_hook
        Around do |object, block|
          unless ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED']
            KnapsackPro::Hooks::Queue.call_before_queue
            ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED'] = 'true'
          end
          block.call
        end
      end

      def bind_after_queue_hook
        ::Kernel.at_exit do
          # In the preload mode ( KNAPSACK_PRO_CUCUMBER_QUEUE_PRELOAD ) the parent
          # process loads the support code but never executes tests; only the forked
          # child processes that ran a batch of tests should save a report.
          unless KnapsackPro::Adapters::CucumberAdapter.preload_parent_process?
            KnapsackPro::Hooks::Queue.call_after_subset_queue
            KnapsackPro::Report.save_subset_queue_to_file
          end
        end
      end

      def self.preload_parent_process?
        !!ENV['KNAPSACK_PRO_CUCUMBER_PRELOAD_PARENT_PID'] &&
          ENV['KNAPSACK_PRO_CUCUMBER_PRELOAD_PARENT_PID'] == Process.pid.to_s
      end

      private

      def Around(*tag_expressions, &proc)
        if ::Cucumber::VERSION.to_i >= 3
          ::Cucumber::Glue::Dsl.register_rb_hook('around', tag_expressions, proc)
        else
          ::Cucumber::RbSupport::RbDsl.register_rb_hook('around', tag_expressions, proc)
        end
      end
    end
  end
end
