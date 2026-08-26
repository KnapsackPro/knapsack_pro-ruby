# frozen_string_literal: true

module KnapsackPro
  module Runners
    module Queue
      class BaseRunner
        TerminationError = Class.new(StandardError)

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
          time_tracker = args.fetch(:time_tracker, nil)
          allocator.test_file_paths(can_initialize_queue, executed_test_files, time_tracker: time_tracker)
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
          Signal.trap("TERM") {
            puts "SIGTERM received: Terminating Knapsack Pro..."
            @@terminate_process = true
            post_trap_signals(debug: true)
            log_threads
          }

          Signal.trap("INT") {
            if @@terminate_process
              puts "SIGINT received: Terminated Knapsack Pro."
              $stdout.flush
              exit!(1)
            else
              puts "SIGINT received: Terminating Knapsack Pro... Interrupt again to force quit."
              @@terminate_process = true
              post_trap_signals
            end
          }
        end

        def post_trap_signals(debug: false)
        end

        def log_threads
          threads = Thread.list

          puts
          puts '=' * 80
          puts "Start logging #{threads.count} detected threads."
          puts 'Use the following backtrace(s) to find the line of code that got stuck if the CI node hung and terminated your tests.'
          puts 'How to read the backtrace: https://knapsackpro.com/perma/ruby/backtrace-debugging'

          log_current_tests(threads)

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

        def log_current_tests(threads)
          # implement in a child class if you need to log more info
        end
      end
    end
  end
end
