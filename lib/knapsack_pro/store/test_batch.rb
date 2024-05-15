# frozen_string_literal: true

module KnapsackPro
  module Store
    class TestBatch
      BatchNotExecutedError = Class.new(StandardError)

      attr_reader :test_file_paths

      def initialize(test_file_paths)
        @test_file_paths = test_file_paths
        @passed = nil
      end

      def executed?
        !@passed.nil?
      end

      def passed?
        raise BatchNotExecutedError.new unless executed?
        return @passed
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
