module KnapsackPro
  module Adapters
    class CucumberAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'features/**{,/*/**}/*.feature'

      def self.test_path(scenario_or_outline_table)
        if scenario_or_outline_table.respond_to?(:file)
          scenario_or_outline_table.file
        else
          scenario_or_outline_table.scenario_outline.file
        end
      end

      def bind_time_tracker
        Around do |scenario_or_outline_table, block|
          KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::CucumberAdapter.test_path(scenario_or_outline_table)
          KnapsackPro.tracker.start_timer
          block.call
          KnapsackPro.tracker.stop_timer
        end

        ::Kernel.at_exit do
          KnapsackPro.logger.info(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report
        ::Kernel.at_exit do
          KnapsackPro::Report.save
        end
      end

      private

      def Around(*tag_expressions, &proc)
        ::Cucumber::RbSupport::RbDsl.register_rb_hook('around', tag_expressions, proc)
      end
    end
  end
end
