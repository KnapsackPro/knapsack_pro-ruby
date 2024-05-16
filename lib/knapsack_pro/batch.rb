# frozen_string_literal: true

module KnapsackPro
  class Batch
    NotExecutedError = Class.new(StandardError)

    attr_reader :test_file_paths

    def initialize(test_file_paths)
      @test_file_paths = test_file_paths
      @passed = nil
    end

    def executed?
      !@passed.nil?
    end

    def passed?
      raise NotExecutedError.new unless executed?
      return @passed
    end

    def _passed
      @passed = true
    end

    def _failed
      @passed = false
    end
  end
end
