# frozen_string_literal: true

module KnapsackPro
  module Formatters
    class TimeTracker
      ::RSpec::Core::Formatters.register self,
        :example_group_started,
        :example_started,
        :example_finished,
        :example_group_finished,
        :stop

      # Called at the beginning of each subset,
      # but only the first instance of this class is used,
      # so don't rely on the initializer to reset values.
      def initialize(_output)
        @time_each = nil
        @time_all = nil
        @before_all = 0.0
        @group = {}
        @subset = {}
        @queue = {}
        @suite_started = now
        @subset_started = now
      end

      def example_group_started(notification)
        return unless top_level_group?(notification.group)
        @time_all = now
      end

      def example_started(_notification)
        @before_all = now - @time_all if @before_all == 0.0
        @time_each = now
      end

      def example_finished(notification)
        record_example(@group, notification.example, @time_each)
        @time_all = now
      end

      def example_group_finished(notification)
        return unless top_level_group?(notification.group)

        add_hooks_time(@group, @before_all, now - @time_all)
        @subset = merge(@subset, @group)
        @before_all = 0.0
        @group = {}
      end

      # Called at the end of each subset
      def stop(_notification)
        @queue = merge(@queue, @subset)
        @subset = {}
        @subset_started = now
      end

      def queue(scheduled_paths)
        recorded_paths = @queue.values.map do |example|
          example[:path].match(/\A(.*?)(?:\[([\d\s:,]+)\])?\z/).captures.first
        end

        missing = (scheduled_paths - recorded_paths).each_with_object({}) do |path, object|
          object[path] = { path: path, time_execution: 0.0 }
        end

        merge(@queue, missing).values.map do |example|
          example.transform_keys(&:to_s)
        end
      end

      def subset
        @subset.values.map do |example|
          example.transform_keys(&:to_s)
        end
      end

      def duration
        now - @suite_started
      end

      def subset_duration
        now - @subset_started
      end

      def unexecuted_test_files(scheduled_paths)
        pending_paths = (@queue.values + @subset.values)
          .filter { |example| example[:time_execution] == 0.0 }
          .map { |example| example[:path] }

        not_run_paths = scheduled_paths -
          (@queue.values + @subset.values)
          .map { |example| example[:path] }

        pending_paths + not_run_paths
      end

      private

      def top_level_group?(group)
        group.metadata[:parent_example_group].nil?
      end

      def add_hooks_time(group, before_all, after_all)
        group.each do |_, example|
          next if example[:time_execution] == 0.0
          example[:time_execution] += before_all + after_all
        end
      end

      def record_example(accumulator, example, started_at)
        path = path_for(example)
        time_execution = time_execution_for(example, started_at)

        if accumulator.key?(path)
          accumulator[path][:time_execution] += time_execution
        else
          accumulator[path] = { path: path, time_execution: time_execution }
        end
      end

      def path_for(example)
        file = file_path_for(example)
        return "UNKNOWN_PATH" if file == ""
        path = rspec_split_by_test_example?(file) ? example.id : file
        KnapsackPro::TestFileCleaner.clean(path)
      end

      def rspec_split_by_test_example?(file)
        return false unless KnapsackPro::Config::Env.queue_recording_enabled?
        return false unless KnapsackPro::Config::Env.rspec_split_by_test_examples?
        return false unless KnapsackPro::Adapters::RSpecAdapter.slow_test_file?(KnapsackPro::Adapters::RSpecAdapter, file)
        true
      end

      def file_path_for(example)
        KnapsackPro::Adapters::RSpecAdapter.file_path_for(example)
      end

      def time_execution_for(example, started_at)
        if example.execution_result.status.to_s == "pending"
          0.0
        else
          (now - started_at).to_f
        end
      end

      def merge(h1, h2)
        h1.merge(h2) do |key, v1, v2|
          {
            path: key,
            time_execution: v1[:time_execution] + v2[:time_execution]
          }
        end
      end

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
