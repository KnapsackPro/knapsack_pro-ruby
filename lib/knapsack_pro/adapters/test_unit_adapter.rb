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

      def bind_time_tracker
        #Test::Unit.at_start do |a, b|
          #require 'pry'; binding.pry
          ##KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::RSpecAdapter.test_path(current_example_group)
          ##KnapsackPro.tracker.start_timer
        #end
        #::RSpec.configure do |config|
          #config.prepend_before(:each) do
            #current_example_group =
              #if ::RSpec.respond_to?(:current_example)
                #::RSpec.current_example.metadata[:example_group]
              #else
                #example.metadata
              #end
            #KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::RSpecAdapter.test_path(current_example_group)
            #KnapsackPro.tracker.start_timer
          #end

          #config.append_after(:each) do
            #KnapsackPro.tracker.stop_timer
          #end
        #end

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
