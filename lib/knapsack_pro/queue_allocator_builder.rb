# frozen_string_literal: true

module KnapsackPro
  class QueueAllocatorBuilder < BaseAllocatorBuilder
    def allocator
      KnapsackPro::QueueAllocator.new(
        test_suite: test_suite,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        ci_node_build_id: env.ci_node_build_id,
        repository_adapter: repository_adapter,
      )
    end
  end
end
