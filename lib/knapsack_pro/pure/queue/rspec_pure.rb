# frozen_string_literal: true

module KnapsackPro
  module Pure
    module Queue
      class RSpecPure
        FAILURE_EXIT_CODE = 1
        FORMATTERS = [
          'KnapsackPro::Formatters::TimeTracker',
        ]

        attr_reader :adapter_class

        def initialize(adapter_class = KnapsackPro::Adapters::RSpecAdapter, time_tracker_fetcher = KnapsackPro::Formatters::TimeTrackerFetcher)
          @adapter_class = adapter_class
          @time_tracker_fetcher = time_tracker_fetcher
        end

        def add_knapsack_pro_formatters_to(spec_opts)
          return spec_opts unless spec_opts
          return spec_opts if FORMATTERS.all? { |formatter| spec_opts.include?(formatter) }

          FORMATTERS.each do |formatter|
            next if spec_opts.include?(formatter)
            spec_opts += " --format #{formatter}"
          end

          spec_opts
        end

        def error_exit_code(rspec_error_exit_code)
          rspec_error_exit_code || FAILURE_EXIT_CODE
        end

        def args_with_seed_option_added_when_viable(seed, args)
          order_option = @adapter_class.order_option(args)

          return args if order_option && !order_option.include?('rand')
          return args if order_option && order_option.to_s.split(':')[1]

          return args unless seed.used?

          args + ['--seed', seed.value]
        end

        def prepare_cli_args(args, test_dir)
          (args || '').split
            .yield_self { args_with_at_least_one_formatter(_1) }
            .yield_self { args_with_default_options(_1, test_dir) }
        end

        def rspec_command(args, test_file_paths, scope)
          messages = []
          return messages if test_file_paths.empty?

          case scope
          when :batch_finished
            messages << 'To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:'
          when :queue_finished
            messages << 'To retry all the tests assigned to this CI node, please run the following command on your machine:'
          end

          stringified_cli_args = args.join(' ')
          FORMATTERS.each do |formatter|
            stringified_cli_args.sub!(" --format #{formatter}", '')
          end

          messages << "bundle exec rspec #{stringified_cli_args} " + KnapsackPro::TestFilePresenter.stringify_paths(test_file_paths)

          messages
        end

        def exit_summary(node_test_file_paths)
          time_tracker = @time_tracker_fetcher.call
          return unless time_tracker

          unexecuted_test_files = time_tracker.unexecuted_test_files(node_test_file_paths)
          return if unexecuted_test_files.empty?

          "Unexecuted tests on this CI node (including pending tests): #{unexecuted_test_files.join(' ')}"
        end

        private

        def args_with_at_least_one_formatter(cli_args)
          return cli_args if @adapter_class.has_format_option?(cli_args)

          cli_args + ['--format', 'progress']
        end

        def args_with_default_options(cli_args, test_dir)
          new_cli_args = cli_args + [
            '--default-path', test_dir,
          ]

          FORMATTERS.each do |formatter|
            new_cli_args += ['--format', formatter]
          end

          new_cli_args
        end
      end
    end
  end
end
