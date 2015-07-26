module KnapsackPro
  class TestFilePattern
    def self.call(adapter_class)
      KnapsackPro::Config::Env.test_file_pattern || adapter_class::TEST_DIR_PATTERN
    end
  end
end
