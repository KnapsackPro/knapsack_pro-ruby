# frozen_string_literal: true

module KnapsackPro
  class Queue
    include Enumerable

    def initialize
      @batches = []
    end

    def each(&block)
      @batches.each(&block)
    end

    def add_batch_for(test_file_paths)
      return if test_file_paths.empty?
      @batches << KnapsackPro::Batch.new(test_file_paths)
    end

    def mark_batch_passed
      current_batch._passed
    end

    def mark_batch_failed
      current_batch._failed
    end

    def current_batch
      @batches.last
    end

    def size
      @batches.size
    end

    def [](index)
      @batches[index]
    end
  end
end
