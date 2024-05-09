# frozen_string_literal: true

module KnapsackPro
  module Store
    class QueueBatchManager
      class TestsBatch
        TestFilesNotExecutedError = Class.new(StandardError)

        attr_reader :test_file_paths

        def initialize(test_file_paths)
          @test_file_paths = test_file_paths
          @passed = nil
        end

        def executed?
          !@passed.nil?
        end

        def passed?
          return @passed if executed?
          raise TestFilesNotExecutedError.new
        end

        private

        def passed!
          @passed = true
        end

        def failed!
          @passed = false
        end
      end

      attr_reader :batches

      def initialize
        @batches = []
      end

      def add_batch(test_file_paths)
        @batches << TestsBatch.new(test_file_paths)
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
