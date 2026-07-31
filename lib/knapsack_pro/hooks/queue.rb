# frozen_string_literal: true

module KnapsackPro
  module Hooks
    class Queue
      class << self
        attr_reader :before_queue_store,
          :before_subset_queue_store,
          :after_subset_queue_store,
          :after_queue_store,
          :after_preload_fork_store

        def reset_before_queue
          @before_queue_store = nil
        end

        def reset_before_subset_queue
          @before_subset_queue_store = nil
        end

        def reset_after_subset_queue
          @after_subset_queue_store = nil
        end

        def reset_after_queue
          @after_queue_store = nil
        end

        def reset_after_preload_fork
          @after_preload_fork_store = nil
        end

        def before_queue(&block)
          @before_queue_store ||= []
          @before_queue_store << block
        end

        def before_subset_queue(&block)
          @before_subset_queue_store ||= []
          @before_subset_queue_store << block
        end

        def after_subset_queue(&block)
          @after_subset_queue_store ||= []
          @after_subset_queue_store << block
        end

        def after_queue(&block)
          @after_queue_store ||= []
          @after_queue_store << block
        end

        # Called in a forked child process right after the fork when the Cucumber
        # preload mode ( KNAPSACK_PRO_CUCUMBER_QUEUE_PRELOAD ) is enabled.
        # Use it to re-establish resources that do not survive a fork,
        # e.g., reopen log appenders or reconnect clients holding sockets.
        def after_preload_fork(&block)
          @after_preload_fork_store ||= []
          @after_preload_fork_store << block
        end

        def call_after_preload_fork
          return unless after_preload_fork_store
          after_preload_fork_store.each(&:call)
        end

        def call_before_queue
          return unless before_queue_store
          before_queue_store.each do |block|
            block.call(
              KnapsackPro::Config::Env.queue_id
            )
          end
        end

        # `queue` is always present for RSpec
        def call_before_subset_queue(queue = nil)
          return unless before_subset_queue_store
          before_subset_queue_store.each do |block|
            block.call(
              KnapsackPro::Config::Env.queue_id,
              KnapsackPro::Config::Env.subset_queue_id,
              queue
            )
          end
        end

        def call_after_subset_queue(queue = nil)
          return unless after_subset_queue_store
          after_subset_queue_store.each do |block|
            block.call(
              KnapsackPro::Config::Env.queue_id,
              KnapsackPro::Config::Env.subset_queue_id,
              queue
            )
          end
        end

        def call_after_queue
          return unless after_queue_store
          after_queue_store.each do |block|
            block.call(
              KnapsackPro::Config::Env.queue_id
            )
          end
        end
      end
    end
  end
end
