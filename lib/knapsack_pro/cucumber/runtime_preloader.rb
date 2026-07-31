# frozen_string_literal: true

require 'shellwords'

module KnapsackPro
  module Cucumber
    class RuntimePreloader
      # Cucumber::Runtime memoizes these based on the configuration it was
      # first run with. When the runtime is reused for another run via
      # Cucumber::Cli::Main#execute!(existing_runtime), they must be reset so
      # that reports, formatters, and parsed feature files are rebuilt against
      # the new configuration and its event bus. Without this, test results
      # are published to the previous run's event bus: formatters print
      # nothing and the process exits 0 even when scenarios fail.
      RUNTIME_MEMOIZED_IVARS = %i[
        @features
        @filespecs
        @report
        @summary_report
        @fail_fast_report
        @publish_banner_printer
        @formatters
      ].freeze

      # Boots Cucumber once (a dry run loads the support code, e.g.
      # features/support/env.rb which usually boots a Rails app) and returns
      # the runtime so batches can be executed in forked child processes
      # without paying the boot cost again.
      def self.preload(test_dir, args)
        unless Process.respond_to?(:fork)
          raise "KNAPSACK_PRO_CUCUMBER_QUEUE_PRELOAD requires an operating system that supports Process.fork (POSIX). Please disable the preload mode."
        end

        require 'cucumber'

        # The parent process must not run the adapter's at_exit hooks
        # (saving a subset queue report to disk / calling queue hooks);
        # only the forked children that actually execute tests should.
        # See lib/knapsack_pro/adapters/cucumber_adapter.rb
        ENV['KNAPSACK_PRO_CUCUMBER_PRELOAD_PARENT_PID'] = Process.pid.to_s

        KnapsackPro.logger.info('Preloading Cucumber (loading support code once; batches will run in forked processes).')

        cli_args_without_formatters = KnapsackPro::Adapters::CucumberAdapter.remove_formatters(Shellwords.split(args || ''))
        cli_args = cli_args_without_formatters + [
          '--dry-run',
          '--format', 'progress',
          '--out', File::NULL,
          '--require', test_dir,
        ]

        # Cucumber's option parser mutates the args array, so build the debug command upfront.
        command = (['bundle exec cucumber'] + cli_args).join(' ')

        runtime = ::Cucumber::Runtime.new
        exit_code =
          begin
            ::Cucumber::Cli::Main.new(cli_args).execute!(runtime)
            0
          rescue SystemExit => e
            e.status
          end

        unless exit_code.zero?
          raise "Failed to preload Cucumber (exit code #{exit_code}). To reproduce the problem, run: #{command}"
        end

        runtime
      end

      def self.reset_runtime_memoization(runtime)
        RUNTIME_MEMOIZED_IVARS.each do |ivar|
          runtime.remove_instance_variable(ivar) if runtime.instance_variable_defined?(ivar)
        end
      end
    end
  end
end
