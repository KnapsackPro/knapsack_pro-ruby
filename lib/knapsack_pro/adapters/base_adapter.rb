module KnapsackPro
  module Adapters
    class BaseAdapter
      # Just example, please overwrite constant in subclass
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'

      def self.slow_test_file?(adapter_class, test_file_path)
        @slow_test_file_paths ||=
          begin
            slow_test_files =
              if KnapsackPro::Config::Env.slow_test_file_pattern
                KnapsackPro::TestFileFinder.slow_test_files_by_pattern(adapter_class)
              else
                # get slow test files from JSON file based on data from API
                KnapsackPro::SlowTestFileDeterminer.read_from_json_report
              end
            KnapsackPro::TestFilePresenter.paths(slow_test_files)
          end
        clean_path = KnapsackPro::TestFileCleaner.clean(test_file_path)
        @slow_test_file_paths.include?(clean_path)
      end

      def self.bind
        adapter = new
        adapter.bind
        adapter
      end

      def bind
        if KnapsackPro::Config::Env.recording_enabled?
          KnapsackPro.logger.debug('Test suite time execution recording enabled.')
          bind_time_tracker
          bind_save_report
        end

        if KnapsackPro::Config::Env.queue_recording_enabled?
          KnapsackPro.logger.debug('Test suite time execution queue recording enabled.')
          bind_queue_mode
        end
      end

      def bind_time_tracker
        raise NotImplementedError
      end

      def bind_save_report
        raise NotImplementedError
      end

      def bind_before_queue_hook
        raise NotImplementedError
      end

      def bind_queue_mode
        bind_before_queue_hook
        bind_time_tracker
      end
    end
  end
end
