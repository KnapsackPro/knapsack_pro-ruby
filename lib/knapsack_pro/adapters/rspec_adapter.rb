module KnapsackPro
  module Adapters
    class RSpecAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'spec/**{,/*/**}/*_spec.rb'

      def self.test_path(example_group)
        if defined?(Turnip) && Turnip::VERSION.to_i < 2
          unless example_group[:turnip]
            until example_group[:parent_example_group].nil?
              example_group = example_group[:parent_example_group]
            end
          end
        else
          until example_group[:parent_example_group].nil?
            example_group = example_group[:parent_example_group]
          end
        end

        example_group[:file_path]
      end

      def bind_time_tracker
        ::RSpec.configure do |config|
          config.prepend_before(:each) do
            current_example_group =
              if ::RSpec.respond_to?(:current_example)
                ::RSpec.current_example.metadata[:example_group]
              else
                example.metadata
              end
            KnapsackPro.tracker.current_test_path = KnapsackPro::Adapters::RSpecAdapter.test_path(current_example_group)
            KnapsackPro.tracker.start_timer
          end

          config.append_after(:each) do
            KnapsackPro.tracker.stop_timer
          end

          config.after(:suite) do
            KnapsackPro.logger.debug(KnapsackPro::Presenter.global_time)
          end
        end
      end

      def bind_save_report
        ::RSpec.configure do |config|
          config.after(:suite) do
            KnapsackPro::Report.save
          end
        end
      end

      def bind_save_queue_report
        ::RSpec.configure do |config|
          config.after(:suite) do
            KnapsackPro::Report.save_subset_queue_to_file
          end
        end
      end

      def bind_tracker_reset
        ::RSpec.configure do |config|
          config.before(:suite) do
            KnapsackPro.tracker.reset!
          end
        end
      end

      def bind_before_queue_hook
        ::RSpec.configure do |config|
          config.before(:suite) do
            unless ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED']
              KnapsackPro::Hooks::Queue.call_before_queue
              ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED'] = 'true'
            end
          end
        end
      end
    end

    # This is added to provide backwards compatibility
    # In case someone is doing switch from knapsack gem to the knapsack_pro gem
    # and didn't notice the class name changed
    class RspecAdapter < RSpecAdapter
    end
  end
end
