module KnapsackPro
  class Tracker
    include Singleton

    attr_reader :global_time_since_beginning, :global_time, :test_files_with_time
    attr_writer :current_test_path

    def initialize
      @global_time_since_beginning = 0
      set_defaults
    end

    def reset!
      set_defaults
    end

    def start_timer
      @start_time = now_without_mock_time.to_f
    end

    def stop_timer
      execution_time = @start_time ? now_without_mock_time.to_f - @start_time : 0.0
      update_global_time(execution_time)
      update_test_file_time(execution_time)
      execution_time
    end

    def current_test_path
      raise("current_test_path needs to be set by Knapsack Pro Adapter's bind method") unless @current_test_path
      @current_test_path.sub(/^\.\//, '')
    end

    def set_prerun_tests(test_file_paths)
      test_file_paths.each do |test_file_path|
        # Set a default time for test file
        # in case when the test file will not be run
        # due syntax error or being pending.
        # The time is required by Knapsack Pro API.
        @test_files_with_time[test_file_path] = 0.1
      end
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

    def update_global_time(execution_time)
      @global_time += execution_time
      @global_time_since_beginning += execution_time
    end

    def update_test_file_time(execution_time)
      @test_files_with_time[current_test_path] ||= 0
      @test_files_with_time[current_test_path] += execution_time
    end

    def now_without_mock_time
      if defined?(Timecop)
        Time.now_without_mock_time
      else
        Time.raw_now
      end
    end
  end
end
