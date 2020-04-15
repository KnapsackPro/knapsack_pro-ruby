module KnapsackPro
  class QueueAllocatorBuilder < BaseAllocatorBuilder
    def allocator
      original_test_files = test_files

      # binding.pry

      # ::Rspec::World

      KnapsackPro::QueueAllocator.new(
        test_files: original_test_files,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        ci_node_build_id: env.ci_node_build_id,
        repository_adapter: repository_adapter,
      )
    end
  end
end
