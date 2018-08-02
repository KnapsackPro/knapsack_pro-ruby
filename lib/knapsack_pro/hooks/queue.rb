module KnapsackPro
  module Hooks
    class Queue
      class << self
        attr_reader :before_queue,
          :after_subset_queue,
          :after_queue

        def reset_before_queue
          @before_queue = nil
        end

        def reset_after_subset_queue
          @after_subset_queue = nil
        end

        def reset_after_queue
          @after_queue = nil
        end

        def before_queue(&block)
          @before_queue ||= block
        end

        def after_subset_queue(&block)
          @after_subset_queue ||= block
        end

        def after_queue(&block)
          @after_queue ||= block
        end

        def call_before_queue
          return unless before_queue
          before_queue.call(
            KnapsackPro::Config::Env.queue_id
          )
        end

        def call_after_subset_queue
          return unless after_subset_queue
          after_subset_queue.call(
            KnapsackPro::Config::Env.queue_id,
            KnapsackPro::Config::Env.subset_queue_id
          )
        end

        def call_after_queue
          return unless after_queue
          after_queue.call(
            KnapsackPro::Config::Env.queue_id
          )
        end
      end
    end
  end
end
