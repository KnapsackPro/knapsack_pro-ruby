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
        @time_all_by_group_id_path = Hash.new(0)
        @group = {}
        @paths = {}
        @suite_started = now
        @batched_scheduled_paths = []
        @split_by_test_example_file_paths = Set.new
        @current_batch_failed_examples = []
      end

      def current_batch_failed_id_paths
        @current_batch_failed_examples.map { |example| KnapsackPro::TestFileCleaner.clean(example.id) }
      end

      def schedule(paths)
        @current_batch_failed_examples = []
        @batched_scheduled_paths << paths

        paths.each do |path|
          next unless KnapsackPro::Adapters::RSpecAdapter.id_path?(path)

          file_path = KnapsackPro::Adapters::RSpecAdapter.parse_file_path(path)
          @split_by_test_example_file_paths << file_path
        end
      end

      def example_group_started(notification)
        record_time_all(notification.group.parent_groups[1], @time_all_by_group_id_path, @time_all)
        @time_all = now
      end

      def example_started(notification)
        record_time_all(notification.example.example_group, @time_all_by_group_id_path, @time_all)
        @time_each = now
      end

      def example_finished(notification)
        record_example(@group, notification.example, @time_each)
        @time_all = now
      end

      def example_group_finished(notification)
        record_time_all(notification.group, @time_all_by_group_id_path, @time_all)
        @time_all = now
        return unless top_level_group?(notification.group)

        add_hooks_time(@group, @time_all_by_group_id_path)
        @time_all_by_group_id_path = Hash.new(0)
        @paths = merge(@paths, @group)
        @group = {}
      end

      def queue
        recorded_paths = @paths.values.map do |example|
          KnapsackPro::Adapters::RSpecAdapter.parse_file_path(example[:path])
        end

        missing = (@batched_scheduled_paths.flatten - recorded_paths).each_with_object({}) do |path, object|
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

      def unexecuted_test_paths
        pending_paths = @paths.values
          .filter { |example| example[:time_execution] == 0.0 }
          .map { |example| example[:path] }

        not_run_paths = @batched_scheduled_paths.flatten -
          @paths.values
          .map { |example| example[:path] }

        pending_paths + not_run_paths
      end

      private

      def top_level_group?(group)
        group.metadata[:parent_example_group].nil?
      end

      def add_hooks_time(group, time_all_by_group_id_path)
        group.each do |_, example|
          next if example[:time_execution] == 0.0

          example[:time_execution] += time_all_by_group_id_path.reduce(0.0) do |sum, (group_id_path, time)|
            # :path is a file path (a_spec.rb), sum any before/after(:all) in the file
            next sum + time if group_id_path.start_with?(example[:path])
            # :path is an id path (a_spec.rb[1:1]), sum any before/after(:all) above it
            next sum + time if example[:path].start_with?(group_id_path[0..-2])
            sum
          end
        end
      end

      def record_example(accumulator, example, started_at)
        path = path_for(example)
        return if path.nil?

        @current_batch_failed_examples << example if example.execution_result.status.to_s == "failed"

        time_execution = time_execution_for(example, started_at)
        if accumulator.key?(path)
          accumulator[path][:time_execution] += time_execution
        else
          accumulator[path] = { path: path, time_execution: time_execution }
        end
      end

      def record_time_all(group, time_all_by_group_id_path, time_all)
        return unless group # above top level group

        group_id_path = KnapsackPro::TestFileCleaner.clean(group.id)
        time_all_by_group_id_path[group_id_path] += now - time_all
      end

      def path_for(example)
        file_path = file_path_for(example)
        return nil if file_path == ""

        if rspec_split_by_test_example?(file_path)
          KnapsackPro::TestFileCleaner.clean(example.id)
        else
          file_path
        end
      end

      def rspec_split_by_test_example?(file_path)
        @split_by_test_example_file_paths.include?(file_path)
      end

      def file_path_for(example)
        KnapsackPro::TestFileCleaner.clean(KnapsackPro::Adapters::RSpecAdapter.file_path_for(example))
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
