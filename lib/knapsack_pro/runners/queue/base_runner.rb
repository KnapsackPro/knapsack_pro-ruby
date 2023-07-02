module KnapsackPro
  module Runners
    module Queue
      class BaseRunner
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
          raise 'Knapsack Pro process was terminated!' if @@terminate_process
        end

        def trap_signals
          Signal.trap('HUP') {
            puts '+'*100
            puts 'HUP'
            @@terminate_process = true
          }
          Signal.trap('INT') {
            puts '+'*100
            puts 'INT'
            @@terminate_process = true
          }
          Signal.trap('QUIT') {
            puts '+'*100
            puts 'QUIT'
            @@terminate_process = true
          }
          Signal.trap('USR1') {
            puts '+'*100
            puts 'USR1'
            @@terminate_process = true
          }
          Signal.trap('USR2') {
            puts '+'*100
            puts 'USR2'
            @@terminate_process = true
          }
          Signal.trap('TERM') {
            puts '+'*100
            puts 'TERM'
            @@terminate_process = true
          }
          Signal.trap('ABRT') {
            puts '+'*100
            puts 'ABRT'
            @@terminate_process = true
          }
        end
      end
    end
  end
end
