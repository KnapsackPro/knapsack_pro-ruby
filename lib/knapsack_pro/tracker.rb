module KnapsackPro
  class Tracker
    include Singleton

    # when test file is pending, empty with no tests or has syntax error then assume time execution
    # to better allocate it in Queue Mode for future CI build runs
    DEFAULT_TEST_FILE_TIME = 0.1 # seconds

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
      KnapsackPro::TestFileCleaner.clean(@current_test_path)
    end

    def set_prerun_tests(test_file_paths)
      test_file_paths.each do |test_file_path|
        # Set a default time for test file
        # in case when the test file will not be run
        # due syntax error or being pending.
        # The time is required by Knapsack Pro API.
        @test_files_with_time[test_file_path] = {
          time_execution: DEFAULT_TEST_FILE_TIME,
          measured_time: false,
        }
      end
    end

    def to_a
      test_files = []
      @test_files_with_time.each do |path, hash|
        test_files << {
          path: path,
          time_execution: hash[:time_execution]
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
      @test_files_with_time[current_test_path] ||= {
        time_execution: 0,
        measured_time: false,
      }

      hash = @test_files_with_time[current_test_path]

      if hash[:measured_time]
        hash[:time_execution] += execution_time
      else
        hash[:time_execution] = execution_time
        hash[:measured_time] = true
      end

      @test_files_with_time[current_test_path] = hash
    end

    def now_without_mock_time
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
