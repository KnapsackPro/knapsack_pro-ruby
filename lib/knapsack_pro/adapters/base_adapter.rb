module KnapsackPro
  module Adapters
    class BaseAdapter
      # Just example, please overwrite constant in subclass
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'

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

      def bind_save_queue_report
        raise NotImplementedError
      end

      def bind_tracker_reset
        raise NotImplementedError
      end

      def bind_before_queue_hook
        raise NotImplementedError
      end

      private

      def bind_queue_mode
        bind_tracker_reset
        bind_before_queue_hook
        bind_time_tracker
        bind_save_queue_report
      end
    end
  end
end
