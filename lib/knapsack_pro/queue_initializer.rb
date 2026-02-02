# frozen_string_literal: true

module KnapsackPro
  module RSpec
    class QueueInitializer
      def call(args)
        slow_id_paths = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new.calculate_slow_id_paths(args.to_s)
        all_test_files_to_run = KnapsackPro::TestSuite.new(KnapsackPro::Adapters::RSpecAdapter).all_test_files_to_run
        paths = KnapsackPro::Adapters::RSpecAdapter.concat_paths(all_test_files_to_run, slow_id_paths)

        raise 'No paths to run' if paths.empty?
        action = KnapsackPro::Client::API::V1::Queues.initialize(paths)
        connection = KnapsackPro::Client::Connection.new(action)
        response = connection.call

        unless connection.success?
          KnapsackPro.logger.warn "Failed to initialize the test queue. Knapsack Pro will initialize it right before running the tests."
          exit 1
        end

        if connection.errors?
          KnapsackPro.logger.warn "Failed to initialize the test queue. Knapsack Pro will initialize it right before running the tests."
          KnapsackPro.logger.warn response.inspect
          exit 1
        end

        # Not present if this node lost the race to initialize to another parallel node.
        if response.key?('url')
          KnapsackPro.logger.info "Build URL: #{response.fetch('url')}"
        end
      end
    end
  end
end
