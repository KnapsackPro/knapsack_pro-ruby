module KnapsackPro
  module Adapters
    class BaseAdapter
      # Just example, please overwrite constant in subclass
      TEST_DIR_PATTERN = 'test/**/*_test.rb'

      def self.bind
        adapter = new
        adapter.bind
        adapter
      end

      def bind
        if KnapsackPro::Config::Env.recording_enabled?
          KnapsackPro.logger.info('Knapsack Pro test suite time execution recording enabled.')
          bind_time_tracker
          bind_save_report
        end
      end

      def bind_time_tracker
        raise NotImplementedError
      end

      def bind_save_report
        raise NotImplementedError
      end
    end
  end
end
