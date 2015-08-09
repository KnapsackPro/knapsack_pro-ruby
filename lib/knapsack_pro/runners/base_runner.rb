module KnapsackPro
  module Runners
    class BaseRunner
      def initialize(adapter_class)
        @allocator_builder = KnapsackPro::AllocatorBuilder.new(adapter_class)
        @allocator = allocator_builder.allocator
      end

      def test_file_paths
        allocator.test_file_paths
      end

      def stringify_test_file_paths
        KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)
      end

      def test_dir
        allocator_builder.test_dir
      end

      private

      attr_reader :allocator_builder,
        :allocator
    end
  end
end
