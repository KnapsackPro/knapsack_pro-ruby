module KnapsackPro
  class Tracker
    include Singleton

    attr_reader :global_time, :test_files_with_time
    attr_writer :current_test_path

    def initialize
      set_defaults
    end

    def reset!
      set_defaults
    end

    def start_timer
      @start_time = now_without_mock_time.to_f
    end

    def stop_timer
      @execution_time = now_without_mock_time.to_f - @start_time
      update_global_time
      update_test_file_time
      @execution_time
    end

    def current_test_path
      raise("current_test_path needs to be set by Knapsack Pro Adapter's bind method") unless @current_test_path
      @current_test_path.sub(/^\.\//, '')
    end

    def to_a
      test_files = []
      @test_files_with_time.each do |path, time_execution|
        test_files << {
          path: path,
          time_execution: time_execution
        }
      end
      test_files
    end

    private

    def set_defaults
      @global_time = 0
      @test_files_with_time = {}
      @test_path = nil
    end

    def update_global_time
      @global_time += @execution_time
    end

    def update_test_file_time
      @test_files_with_time[current_test_path] ||= 0
      @test_files_with_time[current_test_path] += @execution_time
    end

    def now_without_mock_time
      if defined?(Timecop)
        Time.now_without_mock_time
      else
        Time.now
      end
    end
  end
end
