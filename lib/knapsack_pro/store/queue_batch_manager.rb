# frozen_string_literal: true

module KnapsackPro
  module Store
    class QueueBatchManager
      attr_reader :batches

      def initialize
        @batches = []
      end

      def add_batch(test_file_paths)
        @batches << KnapsackPro::Store::TestsBatch.new(test_file_paths)
      end

      def last_batch_passed!
        @batches.last.send(:passed!)
      end

      def last_batch_failed!
        @batches.last.send(:failed!)
      end
    end
  end
end
