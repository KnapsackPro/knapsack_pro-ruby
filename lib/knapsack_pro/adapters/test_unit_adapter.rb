module KnapsackPro
  module Adapters
    class TestUnitAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'test/**{,/*/**}/*_test.rb'

      def self.test_path(example_group)
        #if defined?(Turnip) && Turnip::VERSION.to_i < 2
          #unless example_group[:turnip]
            #until example_group[:parent_example_group].nil?
              #example_group = example_group[:parent_example_group]
            #end
          #end
        #else
          #until example_group[:parent_example_group].nil?
            #example_group = example_group[:parent_example_group]
          #end
        #end

        #example_group[:file_path]
      end

      # FIXME
      module BindTimeTrackerTestUnitPlugin
        def setup
          super
          puts '/'*10
          puts 'SETUP plugin'
          #KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::TestUnitAdapter.test_path(self)
          #KnapsackPro.tracker.start_timer
        end

        def teardown
          #KnapsackPro.tracker.stop_timer
          puts '/'*10
          puts 'SETUP teardown'
          super
        end
      end

      def bind_time_tracker
        Test::Unit::TestCase.send(:include, BindTimeTrackerTestUnitPlugin)

        Test::Unit.at_exit do
          KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
        end
      end

      def bind_save_report
        Test::Unit.at_exit do
          KnapsackPro::Report.save
        end
      end
    end
  end
end
