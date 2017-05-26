module KnapsackPro
  module Hooks
    class Queue
      class << self
        attr_reader :after_subset_queue

        def reset_after_subset_queue
          @after_subset_queue = nil
        end

        def after_subset_queue(&block)
          @after_subset_queue ||= block
        end

        def call_after_subset_queue
          return unless after_subset_queue
          after_subset_queue.call(
            KnapsackPro::Config::Env.queue_id,
            KnapsackPro::Config::Env.subset_queue_id
          )
        end
      end
    end
  end
end
