module KnapsackPro
  module Runners
    module Queue
      class BaseQueueRunner
        def self.run(args)
          raise NotImplementedError
        end

        def initialize(adapter_class)
          @allocator_builder = KnapsackPro::QueueAllocatorBuilder.new(adapter_class)
          @allocator = allocator_builder.allocator
        end

        def test_file_paths(args)
          can_initialize_queue = args.fetch(:can_initialize_queue)
          allocator.test_file_paths(can_initialize_queue)
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
end
