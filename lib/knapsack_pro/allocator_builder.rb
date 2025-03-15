# frozen_string_literal: true

module KnapsackPro
  class AllocatorBuilder < BaseAllocatorBuilder
    def allocator
      KnapsackPro::Allocator.new(
        test_suite_builder: test_suite_builder,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        repository_adapter: repository_adapter,
      )
    end
  end
end
