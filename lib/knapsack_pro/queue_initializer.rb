# frozen_string_literal: true

module KnapsackPro
  module RSpec
    class QueueInitializer
      def call(args)
        slow_id_paths = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new.calculate_slow_id_paths(args.to_s)
        all_test_files_to_run = KnapsackPro::TestSuite.new(KnapsackPro::Adapters::RSpecAdapter).all_test_files_to_run
        paths = KnapsackPro::Adapters::RSpecAdapter.concat_paths(all_test_files_to_run, slow_id_paths)

        raise 'No paths to run' if paths.empty?
        action = KnapsackPro::Client::API::V2::Queues.initialize(paths)
        connection = KnapsackPro::Client::Connection.new(action)
        response = connection.call
        return unless response.key?('url') # Race to initialize lost to another parallel node

        KnapsackPro.logger.info "Build URL: #{response.fetch('url')}"
      end
    end
  end
end
