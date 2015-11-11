module KnapsackPro
  class TestFileFinder
    def self.call(test_file_pattern)
      new(test_file_pattern).call
    end

    def initialize(test_file_pattern)
      @test_file_pattern = test_file_pattern
    end

    def call
      test_file_hashes = []
      test_files.each do |test_file_path|
        test_file_hashes << test_file_hash_for(test_file_path)
      end
      test_file_hashes
    end

    private

    attr_reader :test_file_pattern

    def test_files
      Dir.glob(test_file_pattern).uniq.sort
    end

    def test_file_hash_for(test_file_path)
      {
        'path' => TestFileCleaner.clean(test_file_path)
      }
    end
  end
end
