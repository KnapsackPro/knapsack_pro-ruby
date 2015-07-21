module KnapsackPro
  class Allocator
    def initialize(args={})
      @test_file_pattern = args[:test_file_pattern]
      @ci_node_total = args[:ci_node_total]
      @ci_node_index = args[:ci_node_index]
    end

    def node_tests
      # TODO list of test files from API
    end

    def stringify_node_tests
      node_tests.join(' ')
    end
  end
end
