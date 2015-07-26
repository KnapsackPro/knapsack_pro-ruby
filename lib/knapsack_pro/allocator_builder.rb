module KnapsackPro
  class AllocatorBuilder
    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def allocator
      KnapsackPro::Allocator.new(
        test_files: test_files,
        ci_node_total: env.ci_node_total,
        ci_node_index: env.ci_node_index,
        repository_adapter: repository_adapter,
      )
    end

    def test_dir
      test_file_pattern.split('/').first
    end

    private

    attr_reader :adapter_class

    def env
      KnapsackPro::Config::Env
    end

    def repository_adapter
      KnapsackPro::RepositoryAdapterInitiator.call
    end

    def test_file_pattern
      TestFilePattern.call(adapter_class)
    end

    def test_files
      KnapsackPro::TestFileFinder.call(test_file_pattern)
    end
  end
end
