require 'knapsack_pro'
require 'json'

ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] = SecureRandom.uuid
ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC'] = 'fake-api-token'
ENV['KNAPSACK_PRO_TEST_DIR'] = 'spec_integration'

RSPEC_OPTIONS = ENV.fetch('TEST__RSPEC_OPTIONS')
SHOW_DEBUG_LOG = ENV['TEST__SHOW_DEBUG_LOG'] == 'true'
BATCHED_TESTS = JSON.load(ENV.fetch('TEST__BATCHED_TESTS'))
LAST_BUILD_DISTRIBUTION_RESPONSE = JSON.load(ENV.fetch('TEST__LAST_BUILD_DISTRIBUTION_RESPONSE'))

module KnapsackProExtensions
  module QueueAllocatorExtension
    def test_file_paths(can_initialize_queue, executed_test_files)
      @@batch_index ||= 0
      batches = BATCHED_TESTS + [
        [], # the last Queue API response is always the empty list of test files
      ]
      tests = batches[@@batch_index] || []
      @@batch_index += 1

      if SHOW_DEBUG_LOG
        puts "DEBUG: mocked tests from Queue API: #{tests.inspect}"
      end

      return tests
    end
  end

  module Report
    def create_build_subset(test_files)
      return unless SHOW_DEBUG_LOG
      puts "DEBUG: mocked the #{__method__} method"
    end
  end

  module BuildDistributionFetcher
    def call
      KnapsackPro::BuildDistributionFetcher::BuildDistributionEntity.new(LAST_BUILD_DISTRIBUTION_RESPONSE)
    end
  end
end

# START MOCK API
KnapsackPro::QueueAllocator.prepend(KnapsackProExtensions::QueueAllocatorExtension)
KnapsackPro::BuildDistributionFetcher.prepend(KnapsackProExtensions::BuildDistributionFetcher)

module KnapsackPro
  class Report
    class << self
      prepend KnapsackProExtensions::Report
    end
  end
end
# END OF MOCK API


KnapsackPro::Runners::Queue::RSpecRunner.run(RSPEC_OPTIONS)
