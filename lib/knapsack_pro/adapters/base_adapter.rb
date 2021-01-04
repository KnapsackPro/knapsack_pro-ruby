module KnapsackPro
  module Adapters
    class BaseAdapter
      # Just example, please overwrite constant in subclass
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'

      def self.adapter_bind_method_called_file
        adapter_name = self.to_s.gsub('::', '-')
        "#{KnapsackPro::Config::Env::TMP_DIR}/#{adapter_name}-bind_method_called_for_node_#{KnapsackPro::Config::Env.ci_node_index}.txt"
      end

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

      def self.verify_bind_method_called
        ::Kernel.at_exit do
          if File.exists?(adapter_bind_method_called_file)
            File.delete(adapter_bind_method_called_file)
          else
            puts "\n\n"
            KnapsackPro.logger.error('-'*10 + ' Configuration error ' + '-'*50)
            KnapsackPro.logger.error("You forgot to call #{self}.bind method in your test runner configuration file. It is needed to record test files time execution. Please follow the installation guide to configure your project properly https://docs.knapsackpro.com/knapsack_pro-ruby/guide/")
            KnapsackPro.logger.error("If you already have #{self}.bind method added and you still see this error then one of your tests must had to delete tmp/knapsack_pro directory from the disk accidentally. Please ensure you do not remove tmp/knapsack_pro directory: https://knapsackpro.com/faq/question/why-all-test-files-have-01s-time-execution-for-my-ci-build-in-user-dashboard")
            Kernel.exit(1)
          end
        end
      end

      def bind
        FileUtils.mkdir_p(KnapsackPro::Config::Env::TMP_DIR)
        File.write(self.class.adapter_bind_method_called_file, nil)

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
