# frozen_string_literal: true

module KnapsackPro
  module Runners
    class BaseRunner
      def self.run(args)
        raise NotImplementedError
      end

      def initialize(adapter_class)
        @allocator_builder = KnapsackPro::RegularAllocatorBuilder.new(adapter_class)
        @allocator = allocator_builder.allocator
      end

      def test_file_paths
        @test_file_paths ||= allocator.test_file_paths
      end

      def stringify_test_file_paths
        KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
      end

      def test_dir
        allocator_builder.test_dir
      end

      def test_files_to_execute_exist?
        if test_file_paths.empty?
          KnapsackPro.logger.info("No tests were executed because the test queue is empty.")
          false
        else
          true
        end
      end

      private

      attr_reader :allocator_builder,
        :allocator

      def self.child_status
        $?
      end
    end
  end
end
