# frozen_string_literal: true

module KnapsackPro
  class Batch
    attr_reader :test_file_paths, :status

    def initialize(test_file_paths)
      @test_file_paths = test_file_paths
      @status = :not_executed
    end

    def _passed
      @status = :passed
    end

    def _failed
      @status = :failed
    end
  end
end
