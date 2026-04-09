require 'knapsack_pro'
require 'json'
require 'ostruct'

ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC'] = SecureRandom.hex
ENV['KNAPSACK_PRO_TEST_QUEUE_ID'] = SecureRandom.uuid
ENV['KNAPSACK_PRO_TEST_DIR'] = 'spec_integration'
ENV['KNAPSACK_PRO_TEST_FILE_PATTERN'] = "spec_integration/**{,/*/**}/*_spec.rb"

RSPEC_OPTIONS = ENV.fetch('TEST__RSPEC_OPTIONS')
SHOW_DEBUG_LOG = ENV['TEST__SHOW_DEBUG_LOG'] == 'true'
BATCHES = JSON.load(ENV.fetch('TEST__BATCHES'))

class IntegrationTestLogger
  def self.log(message)
    puts "[INTEGRATION TEST] #{message}"
  end
end

module KnapsackProExtensions
  module QueueAllocatorExtension
    # Succeeds to initialize on the first request
    def initialize_queue_v2(paths, time_tracker)
      # Ensure the stubbed batches match the paths Knapsack Pro wants to run
      raise unless paths.sort == BATCHES.flatten.sort
      test__pull
    end

    # On the first request it fails, but succeeds on the second request
    def pull_tests_from_queue_v2(can_initialize_queue, time_tracker)
      if can_initialize_queue
        connection = OpenStruct.new(success?: true, api_code: KnapsackPro::Client::API::V1::Queues::CODE_ATTEMPT_CONNECT_TO_QUEUE_FAILED)
        KnapsackPro::QueueAllocator::Batch.new(connection, {})
      else
        test__pull
      end
    end

    def test__pull
      last_batch = []
      batches = [*BATCHES, last_batch]
      paths = batches[@batch_index]

      if SHOW_DEBUG_LOG
        IntegrationTestLogger.log("Stubbed paths from the Queue API: #{paths.inspect}")
      end

      connection = OpenStruct.new(success?: true)
      KnapsackPro::QueueAllocator::Batch.new(connection, { "paths" => paths })
    end
  end

  module Report
    def create_build_subset(test_files)
      if ENV['TEST__LOG_EXECUTION_TIMES']
        have_execution_time = test_files.all? { _1.fetch('time_execution') > 0 }
        IntegrationTestLogger.log("test_files: #{test_files.size}, test files have execution time: #{have_execution_time}")
      end

      return unless SHOW_DEBUG_LOG
      IntegrationTestLogger.log("Stubbed the #{__method__} method")
    end
  end

  module RSpecAdapter
    def calculate_slow_id_paths
      JSON.load(ENV.fetch('TEST__SLOW_ID_PATHS'))
    end
  end
end

KnapsackPro::QueueAllocator.prepend(KnapsackProExtensions::QueueAllocatorExtension)
KnapsackPro::Report.singleton_class.prepend(KnapsackProExtensions::Report)
KnapsackPro::Adapters::RSpecAdapter.singleton_class.prepend(KnapsackProExtensions::RSpecAdapter)

KnapsackPro::Runners::Queue::RSpecRunner.run(RSPEC_OPTIONS)
