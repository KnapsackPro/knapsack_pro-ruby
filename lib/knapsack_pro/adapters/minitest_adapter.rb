# frozen_string_literal: true

module KnapsackPro
  module Adapters
    class MinitestAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'
      @@parent_of_test_dir = nil

      def self.test_path(obj)
        path, _line =
          begin
            Object.const_source_location(obj.class.to_s)
          rescue NameError # Dynamically defined class (Minitest::Spec `describe "more words"`)
            nil
          end

        if path.nil? # Dynamically defined class (Minitest::Spec `describe "oneword"`)
          test_method_name = obj.class.runnable_methods.first
          path, _line = obj.method(test_method_name).source_location
        end

        path.gsub(Regexp.new("^#{@@parent_of_test_dir}"), '.')
      end

      module BindTimeTrackerMinitestPlugin
        def run
          path = KnapsackPro::Adapters::MinitestAdapter.test_path(self)
          started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          result = super
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

          failed = result.failures.any? { |failure| !failure.is_a?(::Minitest::Skip) }
          KnapsackPro.tracker.stage(path, elapsed, failed: failed)

          result
        end
      end

      def bind_time_tracker
        ::Minitest::Test.send(:prepend, BindTimeTrackerMinitestPlugin)

        add_post_run_callback do
          KnapsackPro.tracker.flush_staged_tests
          KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report
        add_post_run_callback do
          KnapsackPro.tracker.flush_staged_tests
          KnapsackPro::Report.save(KnapsackPro.tracker.to_a, KnapsackPro.tracker.current_batch_failed_paths)
        end
      end

      def set_test_helper_path(file_path)
        test_dir_path = File.dirname(file_path)
        @@parent_of_test_dir = File.expand_path('../', test_dir_path)
      end

      module BindNormalModeMinitestPlugin
        def run
          unless ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED']
            KnapsackPro::Hooks::Queue.call_before_queue
            ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED'] = 'true'
          end

          path = KnapsackPro::Adapters::MinitestAdapter.test_path(self)
          started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          result = super
          elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at

          failed = result.failures.any? { |failure| !failure.is_a?(::Minitest::Skip) }
          KnapsackPro.tracker.stage(path, elapsed, failed: failed)

          result
        end
      end

      def bind_normal_mode
        ::Minitest::Test.send(:prepend, BindNormalModeMinitestPlugin)

        add_post_run_callback do
          KnapsackPro.tracker.flush_staged_tests
          KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
        end
      end

      private

      def add_post_run_callback(&block)
        if ::Minitest.respond_to?(:after_run)
          ::Minitest.after_run { block.call }
        else
          ::Minitest::Unit.after_tests { block.call }
        end
      end
    end
  end
end
