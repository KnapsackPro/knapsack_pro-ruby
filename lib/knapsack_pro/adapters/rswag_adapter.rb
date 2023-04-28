module KnapsackPro
  module Adapters
    class RswagAdapter < RSpecAdapter
      TEST_DIR_PATTERN = "spec/requests/**/*_spec.rb, spec/api/**/*_spec.rb, spec/integration/**/*_spec.rb"

      def bind_time_tracker
        ::RSpec.configure do |config|
          config.prepend_before(:context) do
            KnapsackPro.tracker.start_timer
          end

          config.around(:each) do |example|
            current_test_path = KnapsackPro::Adapters::RswagAdapter.test_path(example)

            # Stop timer to update time for a previously run test example.
            # This way we count time spent in runtime for the previous test example after around(:each) is already done.
            # Only do that if we're in the same test file. Otherwise, `before(:all)` execution time in the current file
            # will be applied to the previously ran test file.
            if KnapsackPro.tracker.current_test_path&.start_with?(KnapsackPro::TestFileCleaner.clean(current_test_path))
              KnapsackPro.tracker.stop_timer
            end

            KnapsackPro.tracker.current_test_path =
              if KnapsackPro::Config::Env.rspec_split_by_test_examples? && KnapsackPro::Adapters::RswagAdapter.slow_test_file?(RswagAdapter, current_test_path)
                example.id
              else
                current_test_path
              end

            if example.metadata[:focus] && KnapsackPro::Adapters::RswagAdapter.rspec_configuration.filter.rules[:focus]
              raise "We detected a test file path #{current_test_path} with a test using the metadata `:focus` tag. RSpec might not run some tests in the Queue Mode (causing random tests skipping problem). Please remove the `:focus` tag from your codebase. See more: #{KnapsackPro::Urls::RSPEC__SKIPS_TESTS}"
            end

            example.run
          end

          config.append_after(:context) do
            # after(:context) hook is run one time only, after all of the examples in a group
            # stop timer to count time for the very last executed test example
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

      private

      # Hide RSpec configuration so that we could mock it in the spec.
      # Mocking existing RSpec configuration could impact test's runtime.
      def self.rspec_configuration
        ::RSpec.configuration
      end

      def self.parsed_options(cli_args)
        ::RSpec::Core::Parser.parse(cli_args)
      rescue SystemExit
        nil
      end
    end
  end
end
