# frozen_string_literal: true

module KnapsackPro
  module Runners
    class RSpecRunner < BaseRunner
      def self.run(args)
        require 'rspec/core'

        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec
        ENV['KNAPSACK_PRO_REGULAR_MODE_ENABLED'] = 'true'

        adapter_class = KnapsackPro::Adapters::RSpecAdapter
        KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)
        runner = new(adapter_class)

        if runner.test_files_to_execute_exist?
          adapter_class.verify_bind_method_called

          cli_args = (args || '').split
          adapter_class.ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!(cli_args)

          require 'rspec/core/rake_task'

          task_name = 'knapsack_pro:rspec_run'
          if Rake::Task.task_defined?(task_name)
            Rake::Task[task_name].clear
          end

          ::RSpec::Core::RakeTask.new(task_name) do |t|
            # we cannot pass runner.test_file_paths array to t.pattern
            # because pattern does not accept test example path like spec/a_spec.rb[1:2]
            # instead we pass test files and test example paths to t.rspec_opts
            t.pattern = []
            t.rspec_opts = "#{args} #{self.formatters} --default-path #{runner.test_dir} #{runner.stringify_test_file_paths}"
            t.verbose = KnapsackPro::Config::Env.log_level < ::Logger::WARN
          end
          Rake::Task[task_name].invoke
        end
      end

      # Use RSpec::Core::ConfigurationOptions to respect external configurations like .rspec
      def self.formatters
        require_relative '../formatters/time_tracker'

        formatters = ::RSpec::Core::ConfigurationOptions
          .new([])
          .options
          .fetch(:formatters, [])
          .map do |formatter, output|
            arg = "--format #{formatter}"
            arg += " --out #{output}" if output
            arg
          end
        formatters = ['--format progress'] if formatters.empty?
        formatters += ["--format #{KnapsackPro::Formatters::TimeTracker}"]
        formatters.join(' ')
      end
    end
  end
end
