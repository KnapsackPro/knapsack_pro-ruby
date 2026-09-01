# frozen_string_literal: true

module KnapsackPro
  module RSpec
    class TestQueueInitializer
      def call(args)
        test_queue_url, slow_id_paths = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector
          .new
          .calculate_slow_id_paths(args.to_s)
          .values_at(:test_queue_url, :slow_id_paths)

        unless test_queue_url.nil? # The test queue already existed when calculating the slow id paths.
          KnapsackPro.logger.info "Test Queue URL: #{test_queue_url}"
          exit 0
        end

        initialize_test_queue(slow_id_paths)
      end

      private

      def initialize_test_queue(slow_id_paths)
        all_test_files_to_run = KnapsackPro::TestSuite.new(KnapsackPro::Adapters::RSpecAdapter).all_test_files_to_run
        paths = KnapsackPro::Adapters::RSpecAdapter.concat_paths(all_test_files_to_run, slow_id_paths)

        if paths.empty?
          KnapsackPro.logger.error "No paths to run."
          exit 1
        end

        action = KnapsackPro::Client::API::V2::Queues.initialize(paths)
        connection = KnapsackPro::Client::Connection.new(action)
        response = connection.call

        unless connection.success?
          KnapsackPro.logger.error "Failed to initialize the test queue."
          exit 1
        end

        if connection.errors?
          KnapsackPro.logger.error "Failed to initialize the test queue."
          KnapsackPro.logger.error response.inspect
          exit 1
        end

        if response.key?('url')
          KnapsackPro.logger.info "Test Queue URL: #{response.fetch('url')}"
        end

        if response.key?('recommended_node_total')
          KnapsackPro.logger.info "Recommended node_total: #{response.fetch('recommended_node_total')}"
        end
      end
    end
  end
end
