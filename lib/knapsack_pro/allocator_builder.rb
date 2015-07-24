module KnapsackPro
  class AllocatorBuilder
    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def allocator
      KnapsackPro::Allocator.new({
        test_file_pattern: test_file_pattern,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
      })
    end

    def test_dir
      test_file_pattern.split('/').first
    end

    private

    attr_reader :adapter_class

    def env
      KnapsackPro::Config::Env
    end

    def test_file_pattern
      env.test_file_pattern || adapter_class::TEST_DIR_PATTERN
    end
  end
end
