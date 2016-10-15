module KnapsackPro
  module Runners
    module Queue
      class RSpecRunner < BaseRunner
        class Queue
          def initialize(test_file_paths)
            @test_file_paths = test_file_paths
          end

          def test_file_paths
            @test_file_paths.shift
          end
        end

        def self.run_tests(queue, args, runner, exitstatus)
          test_file_paths = queue.test_file_paths

          if test_file_paths.nil?
            exit(exitstatus) unless exitstatus.zero?
          else
            task_name = "knapsack_pro:queue:rspec_run_#{SecureRandom.uuid}"

            RSpec::Core::RakeTask.new(task_name) do |t|
              t.rspec_opts = "#{args} --default-path #{runner.test_dir}"
              t.pattern = test_file_paths
            end

            begin
              Rake::Task[task_name].invoke
            rescue Exception => e
              puts "Task #{task_name} failed"
              puts "#{e.class}: #{e.message}"
              puts "Exit status: #{$?.exitstatus}"
              exitstatus = $?.exitstatus if $?.exitstatus != 0
            end

            at_exit do
              run_tests(queue, args, runner, exitstatus)
            end
          end
        end

        def self.run(args)
          ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
          ENV['KNAPSACK_PRO_RECORDING_ENABLED'] = 'true'

          runner = new(KnapsackPro::Adapters::RSpecAdapter)

          if runner.test_files_to_execute_exist?
            require 'rspec/core/rake_task'

            queue = Queue.new(runner.test_file_paths)
            run_tests(queue, args, runner, 0)
          end
        end
      end
    end
  end
end
