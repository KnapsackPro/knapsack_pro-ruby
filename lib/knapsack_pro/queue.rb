# frozen_string_literal: true

module KnapsackPro
  class Queue
    include Enumerable

    def initialize
      @batches = []
    end

    def each
      @batches.each do |batch|
        yield batch
      end
    end

    def add_batch_for(test_file_paths)
      @batches << KnapsackPro::Batch.new(test_file_paths)
    end

    def mark_batch_passed
      current_batch._passed
    end

    def mark_batch_failed
      current_batch._failed
    end

    private

    def current_batch
      @batches.last
    end
  end
end
