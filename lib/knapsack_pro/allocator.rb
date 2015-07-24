module KnapsackPro
  class Allocator
    attr_reader :test_dir

    def initialize(test_file_pattern:,
                   test_dir:,
                   ci_node_total:,
                   ci_node_index:)
      @test_file_pattern = test_file_pattern
      @test_dir = test_dir
      @ci_node_total = ci_node_total
      @ci_node_index = ci_node_index
    end

    def node_tests
      # TODO list of test files from API
    end

    def stringify_node_tests
      node_tests.join(' ')
    end

    private

    attr_reader :test_file_pattern,
      :ci_node_total,
      :ci_node_index
  end
end
