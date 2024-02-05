require 'knapsack_pro'
require 'json'

ENV['KNAPSACK_PRO_CI_NODE_BUILD_ID'] = SecureRandom.uuid
ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC'] = 'fake-api-token'
ENV['KNAPSACK_PRO_TEST_DIR'] = 'spec_integration'
ENV['KNAPSACK_PRO_TEST_FILE_PATTERN'] = "spec_integration/**{,/*/**}/*_spec.rb"

RSPEC_OPTIONS = ENV.fetch('TEST__RSPEC_OPTIONS')
SHOW_DEBUG_LOG = ENV['TEST__SHOW_DEBUG_LOG'] == 'true'
BATCHED_TESTS = JSON.load(ENV.fetch('TEST__BATCHED_TESTS'))

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
        puts "DEBUG: mocked tests from the Queue API: #{tests.inspect}"
      end

      return tests
    end
  end

  module Report
    def create_build_subset(test_files)
      if ENV['TEST__LOG_EXECUTION_TIMES']
        have_execution_time = test_files.all? { _1.fetch('time_execution') > 0 }
        puts "LOG_EXECUTION_TIMES: test_files: #{test_files.size}, test files have execution time: #{have_execution_time}"
      end

      return unless SHOW_DEBUG_LOG
      puts "DEBUG: mocked the #{__method__} method"
    end
  end

  module RSpecAdapter
    def test_file_cases_for(slow_test_files)
      puts "DEBUG: mocked test file cases for slow test files: #{slow_test_files}"

      test_file_paths = JSON.load(ENV.fetch('TEST__TEST_FILE_CASES_FOR_SLOW_TEST_FILES'))
      test_file_paths.map do |path|
        { 'path' => path }
      end
    end
  end
end

KnapsackPro::QueueAllocator.prepend(KnapsackProExtensions::QueueAllocatorExtension)

module KnapsackPro
  class Report
    class << self
      prepend KnapsackProExtensions::Report
    end
  end
end

module KnapsackPro
  module Adapters
    class RSpecAdapter
      class << self
        prepend KnapsackProExtensions::RSpecAdapter
      end
    end
  end
end

KnapsackPro::Runners::Queue::RSpecRunner.run(RSPEC_OPTIONS)
