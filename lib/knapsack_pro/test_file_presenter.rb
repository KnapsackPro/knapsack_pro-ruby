module KnapsackPro
  class TestFilePresenter
    def self.stringify_paths(test_file_paths)
      test_file_paths.join(' ')
    end

    def self.paths(test_files)
      test_files.map { |t| t['path'] }
    end
  end
end
