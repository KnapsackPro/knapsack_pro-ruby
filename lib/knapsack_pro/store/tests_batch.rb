# frozen_string_literal: true

module KnapsackPro
  module Store
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
  end
end
