# frozen_string_literal: true

module KnapsackPro
  module Runners
    module Queue
      class BaseRunner
        TerminationError = Class.new(StandardError)
        TERMINATION_SIGNALS = %w(HUP INT TERM ABRT QUIT USR1 USR2)

        @@terminate_process = false

        def self.run(args)
          raise NotImplementedError
        end

        def self.run_tests(runner, can_initialize_queue, args, exitstatus)
          raise NotImplementedError
        end

        def initialize(adapter_class)
          @allocator_builder = KnapsackPro::QueueAllocatorBuilder.new(adapter_class)
          @allocator = allocator_builder.allocator
          trap_signals
        end

        def test_file_paths(args)
          can_initialize_queue = args.fetch(:can_initialize_queue)
          executed_test_files = args.fetch(:executed_test_files)
          allocator.test_file_paths(can_initialize_queue, executed_test_files)
        end

        def test_dir
          allocator_builder.test_dir
        end

        private

        attr_reader :allocator_builder,
          :allocator

        def self.child_status
          $?
        end

        def self.handle_signal!
          raise TerminationError.new('Knapsack Pro process was terminated!') if @@terminate_process
        end

        def self.set_terminate_process
          @@terminate_process = true
        end

        def set_terminate_process
          self.class.set_terminate_process
        end

        def trap_signals
          TERMINATION_SIGNALS.each do |signal|
            Signal.trap(signal) {
              puts "#{signal} signal has been received. Terminating Knapsack Pro..."
              @@terminate_process = true
              post_trap_signals
              log_threads
            }
          end
        end

        def post_trap_signals
        end

        def log_threads
          threads = Thread.list

          puts
          puts '=' * 80
          puts "Start logging #{threads.count} detected threads."
          puts 'Use the following backtrace(s) to find the line of code that got stuck if the CI node hung and terminated your tests.'
          puts 'How to read the backtrace: https://knapsackpro.com/perma/ruby/backtrace-debugging'

          threads.each do |thread|
            puts
            if thread == Thread.main
              puts "Main thread backtrace:"
            else
              puts "Non-main thread inspect: #{thread.inspect}"
              puts "Non-main thread backtrace:"
            end
            puts thread.backtrace&.join("\n")
            puts
          end

          puts
          puts 'End logging threads.'
          puts '=' * 80

          $stdout.flush
        end
      end
    end
  end
end
