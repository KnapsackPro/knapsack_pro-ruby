# frozen_string_literal: true

require 'stringio'
require 'set'
require_relative '../utils'

module KnapsackPro
  module Formatters
    class TimeTracker
      ::RSpec::Core::Formatters.register self,
        :example_group_started,
        :example_started,
        :example_finished,
        :example_group_finished

      attr_reader :output # RSpec < v3.10.2

      def initialize(_output)
        @output = StringIO.new
        @time_each = nil
        @time_all = nil
        @before_all = 0.0
        @group = {}
        @paths = {}
        @suite_started = now
        @scheduled_test_file_paths = []
        @scheduled_with_id_paths = Set.new
      end

      def scheduled_test_file_paths=(scheduled_test_file_paths)
        @scheduled_test_file_paths = scheduled_test_file_paths
        upsert_scheduled_with_id_paths
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

        after_all = @time_all.nil? ? 0.0 : now - @time_all
        add_hooks_time(@group, @before_all, after_all)
        @before_all = 0.0
        @paths = merge(@paths, @group)
        @group = {}
      end

      def queue
        recorded_paths = @paths.values.map do |example|
          KnapsackPro::Adapters::RSpecAdapter.parse_file_path(example[:path])
        end

        missing = (@scheduled_test_file_paths - recorded_paths).each_with_object({}) do |path, object|
          object[path] = { path: path, time_execution: 0.0 }
        end

        merge(@paths, missing).values.map do |example|
          example.transform_keys(&:to_s)
        end
      end

      def batch
        @paths.values.map do |example|
          example.transform_keys(&:to_s)
        end
      end

      def duration
        now - @suite_started
      end

      def unexecuted_test_files
        pending_paths = @paths.values
          .filter { |example| example[:time_execution] == 0.0 }
          .map { |example| example[:path] }

        not_run_paths = @scheduled_test_file_paths -
          @paths.values
          .map { |example| example[:path] }

        pending_paths + not_run_paths
      end

      private

      def upsert_scheduled_with_id_paths
        @scheduled_test_file_paths.each do |test_file_path|
          if KnapsackPro::Adapters::RSpecAdapter.rspec_id_path?(test_file_path)
            test_file_path_without_id = KnapsackPro::Adapters::RSpecAdapter.parse_file_path(test_file_path)
            @scheduled_with_id_paths << test_file_path_without_id
          end
        end
      end

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
        return if path.nil?

        time_execution = time_execution_for(example, started_at)
        if accumulator.key?(path)
          accumulator[path][:time_execution] += time_execution
        else
          accumulator[path] = { path: path, time_execution: time_execution }
        end
      end

      def path_for(example)
        file = file_path_for(example)
        return nil if file == ""

        test_file_path = KnapsackPro::TestFileCleaner.clean(file)
        if rspec_split_by_test_example?(test_file_path)
          KnapsackPro::TestFileCleaner.clean(example.id)
        else
          test_file_path
        end
      end

      def rspec_split_by_test_example?(test_file_path)
        @scheduled_with_id_paths.include?(test_file_path)
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
        KnapsackPro::Utils.time_now
      end
    end
  end
end
