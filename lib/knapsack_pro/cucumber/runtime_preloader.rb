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
      #
      # sample_test_file_path limits the dry run to a single test file: the
      # dry run only exists to load the support code, and dry-running a whole
      # test suite can take minutes (e.g., step matching on every step).
      def self.preload(test_dir, args, sample_test_file_path)
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
          # A unique --out path: pointing two formatters at the same stream is an
          # error in Cucumber, and a profile from cucumber.yml may already use
          # --out /dev/null (profiles are expanded before the stream conflict check).
          '--format', 'progress',
          '--out', dry_run_progress_report_path,
          '--require', test_dir,
          sample_test_file_path,
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

        disconnect_active_record_in_parent!

        runtime
      end

      # Database connections opened while booting the app must not be shared
      # with the forked children (concurrent use of an inherited socket
      # corrupts the connection protocol and hangs or fails queries). Clearing
      # the pools here means both the parent and each forked child lazily
      # check out fresh connections when they first need one.
      def self.disconnect_active_record_in_parent!
        return unless defined?(::ActiveRecord::Base)

        ::ActiveRecord::Base.connection_handler.clear_all_connections!
      rescue StandardError => e
        KnapsackPro.logger.warn("Could not clear ActiveRecord connections after preloading Cucumber: #{e.class}: #{e.message}")
      end

      def self.dry_run_progress_report_path
        KnapsackPro::Config::TempFiles.ensure_temp_directory_exists!
        dir = "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/cucumber_queue_preload"
        FileUtils.mkdir_p(dir)
        "#{dir}/dry_run_progress_node_#{KnapsackPro::Config::Env.ci_node_index}.txt"
      end

      def self.reset_runtime_memoization(runtime)
        RUNTIME_MEMOIZED_IVARS.each do |ivar|
          runtime.remove_instance_variable(ivar) if runtime.instance_variable_defined?(ivar)
        end
      end
    end
  end
end
