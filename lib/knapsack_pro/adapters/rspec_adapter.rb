module KnapsackPro
  module Adapters
    class RSpecAdapter < BaseAdapter
      TEST_DIR_PATTERN = 'spec/**{,/*/**}/*_spec.rb'

      def self.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(cli_args)
        if KnapsackPro::Config::Env.rspec_split_by_test_examples? && has_tag_option?(cli_args)
          error_message = 'It is not allowed to use the RSpec tag option together with the RSpec split by test examples feature. Please see: https://knapsackpro.com/faq/question/how-to-split-slow-rspec-test-files-by-test-examples-by-individual-it#warning-dont-use-rspec-tag-option'
          KnapsackPro.logger.error(error_message)
          raise error_message
        end
      end

      def self.has_tag_option?(cli_args)
        # use start_with? because user can define tag option in a few ways:
        # -t mytag
        # -tmytag
        # --tag mytag
        # --tag=mytag
        cli_args.any? { |arg| arg.start_with?('-t') || arg.start_with?('--tag') }
      end

      def self.has_format_option?(cli_args)
        cli_args.any? { |arg| arg.start_with?('-f') || arg.start_with?('--format') }
      end

      def self.test_path(example)
        example_group = example.metadata[:example_group]

        if defined?(::Turnip) && Gem::Version.new(::Turnip::VERSION) < Gem::Version.new('2.0.0')
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
          config.prepend_before(:context) do
            KnapsackPro.tracker.start_timer
          end

          config.around(:each) do |example|
            # stop timer to update time for a previously run test example
            # this way we count time spend in runtime for the previous test example after around(:each) is already done
            KnapsackPro.tracker.stop_timer

            current_test_path = KnapsackPro::Adapters::RSpecAdapter.test_path(example)

            KnapsackPro.tracker.current_test_path =
              if KnapsackPro::Config::Env.rspec_split_by_test_examples? && KnapsackPro::Adapters::RSpecAdapter.slow_test_file?(RSpecAdapter, current_test_path)
                example.id
              else
                current_test_path
              end

            if example.metadata[:focus] && KnapsackPro::Adapters::RSpecAdapter.rspec_configuration.filter.rules[:focus]
              raise "We detected a test file path #{current_test_path} with a test using the metadata `:focus` tag. RSpec might not run some tests in the Queue Mode (causing random tests skipping problem). Please remove the `:focus` tag from your codebase. See more: https://knapsackpro.com/faq/question/rspec-is-not-running-some-tests"
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
    end

    # This is added to provide backwards compatibility
    # In case someone is doing switch from knapsack gem to the knapsack_pro gem
    # and didn't notice the class name changed
    class RspecAdapter < RSpecAdapter
      def self.bind
        error_message = 'You have attempted to call KnapsackPro::Adapters::RspecAdapter.bind. Please switch to using the new class name: KnapsackPro::Adapters::RSpecAdapter. See https://docs.knapsackpro.com/knapsack_pro-ruby/guide for up-to-date configuration instructions.'
        KnapsackPro.logger.error(error_message)
        raise error_message
      end
    end
  end
end
