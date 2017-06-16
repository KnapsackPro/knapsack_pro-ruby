module KnapsackPro
  class BaseAllocatorBuilder
    def initialize(adapter_class)
      @adapter_class = adapter_class
    end

    def allocator
      raise NotImplementedError
    end

    def test_dir
      test_file_pattern.split('/').first.gsub(/({)/, '')
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
