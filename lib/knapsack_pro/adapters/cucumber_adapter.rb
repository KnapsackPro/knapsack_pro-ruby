module KnapsackPro
  module Adapters
    class CucumberAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'features/**{,/*/**}/*.feature'

      def self.test_path(object)
        if Cucumber::VERSION.to_i >= 2
          test_case = object
          test_case.location.file
        else
          if object.respond_to?(:scenario_outline)
            if object.scenario_outline.respond_to?(:feature)
              # Cucumber < 1.3
              object.scenario_outline.feature.file
            else
              # Cucumber >= 1.3
              object.scenario_outline.file
            end
          else
            if object.respond_to?(:feature)
              # Cucumber < 1.3
              object.feature.file
            else
              # Cucumber >= 1.3
              object.file
            end
          end
        end
      end

      def bind_time_tracker
        Around do |object, block|
          KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::CucumberAdapter.test_path(object)
          KnapsackPro.tracker.start_timer
          block.call
          KnapsackPro.tracker.stop_timer
        end

        ::Kernel.at_exit do
          KnapsackPro.logger.info(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report(latest_error = nil)
        ::Kernel.at_exit do
          # $! is latest error message
          latest_error = (latest_error || $!)
          exit_status = latest_error.status if latest_error.is_a?(SystemExit)
          #require 'pry'; binding.pry
          # saving report makes API call which changes exit status
          # from cucumber so we need to preserve cucumber exit status
          KnapsackPro::Report.save
          ::Kernel.exit exit_status if exit_status
        end
      end

      private

      def Around(*tag_expressions, &proc)
        ::Cucumber::RbSupport::RbDsl.register_rb_hook('around', tag_expressions, proc)
      end
    end
  end
end
