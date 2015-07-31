module KnapsackPro
  class Tracker
    include Singleton
    attr_reader :global_time, :test_files_with_time
    attr_writer :test_path
  end
end
