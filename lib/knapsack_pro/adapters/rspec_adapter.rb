module KnapsackPro
  module Adapters
    class RSpecAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'spec/**{,/*/**}/*_spec.rb'

      def self.test_path(example_group)
        if defined?(::Turnip) && ::Turnip::VERSION.to_i < 2
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
          config.around(:each) do |example|
            current_example_group =
              if ::RSpec.respond_to?(:current_example)
                ::RSpec.current_example.metadata[:example_group]
              else
                example.metadata
              end

            current_test_path = KnapsackPro::Adapters::RSpecAdapter.test_path(current_example_group)

            KnapsackPro.tracker.current_test_path =
              if KnapsackPro::Config::Env.rspec_split_by_test_examples? && KnapsackPro::Adapters::RSpecAdapter.slow_test_file?(RSpecAdapter, current_test_path)
                example.id
              else
                current_test_path
              end

            KnapsackPro.tracker.start_timer

            example.run

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

      def bind_before_queue_hook
        ::RSpec.configure do |config|
          config.before(:suite) do
            unless ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED']
              ENV['KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED'] = 'true'
              KnapsackPro::Hooks::Queue.call_before_queue
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
