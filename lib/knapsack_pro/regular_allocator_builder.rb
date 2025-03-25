# frozen_string_literal: true

module KnapsackPro
  class RegularAllocatorBuilder < BaseAllocatorBuilder
    def allocator
      KnapsackPro::RegularAllocator.new(
        test_suite: test_suite,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        repository_adapter: repository_adapter,
      )
    end
  end
end
