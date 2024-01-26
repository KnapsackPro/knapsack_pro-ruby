describe KnapsackPro::Runners::Queue::RSpecRunner do
  before do
    require KnapsackPro.root + '/lib/knapsack_pro/formatters/time_tracker'
  end

  describe described_class::FunctionalCore do
    let(:logger) { instance_double(::Logger) }
    let(:function_core) { described_class.new(logger) }

    describe '#ensure_no_deprecated_run_all_when_everything_filtered_option!' do
      subject { function_core.ensure_no_deprecated_run_all_when_everything_filtered_option!(deprecated_run_all_when_everything_filtered_enabled) }

      context 'when `run_all_when_everything_filtered_enabled` is enabled' do
        let(:deprecated_run_all_when_everything_filtered_enabled) { true }

        it do
          error_message = 'The run_all_when_everything_filtered option is deprecated. See: https://knapsackpro.com/perma/ruby/rspec-deprecated-run-all-when-everything-filtered'
          expect(logger).to receive(:error).with(error_message)
          expect { subject }.to raise_error error_message
        end
      end

      context 'when `run_all_when_everything_filtered_enabled` is disabled' do
        let(:deprecated_run_all_when_everything_filtered_enabled) { false }

        it { expect(subject).to be nil }
      end
    end

    describe '#ensure_spec_opts_have_knapsack_pro_formatters' do
      subject { function_core.ensure_spec_opts_have_knapsack_pro_formatters(spec_opts) }

      context 'when no spec opts' do
        let(:spec_opts) { nil }

        it { expect(subject).to be nil }
      end

      context 'when spec opts have Knapsack Pro formatters' do
        let(:spec_opts) { '--color --format d --format KnapsackPro::Formatters::TimeTracker' }

        it 'returns spec opts' do
          expect(subject).to eq spec_opts
        end
      end

      context 'when spec opts have no Knapsack Pro formatters' do
        let(:spec_opts) { '--color --format d' }

        it 'returns spec opts with added Knapsack Pro formatters' do
          expect(subject).to eq '--color --format d --format KnapsackPro::Formatters::TimeTracker'
        end
      end
    end

    describe '#error_exit_code' do
      subject { function_core.error_exit_code(rspec_error_exit_code) }

      context 'when RSpec has no defined error exit code' do
        let(:rspec_error_exit_code) { nil }

        it 'sets `1` as a default exit code' do
          expect(Kernel).to receive(:exit).with(1)
          subject
        end
      end

      context 'when RSpec has a defined error exit code' do
        let(:rspec_error_exit_code) { 2 }

        it 'sets the custom exit code' do
          expect(Kernel).to receive(:exit).with(2)
          subject
        end
      end
    end

    describe '#to_cli_args' do
      subject { function_core.to_cli_args(args) }

      context 'when args are undefined' do
        let(:args) { nil }

        it { expect(subject).to eq [] }
      end

      context 'when args are an empty string' do
        let(:args) { '' }

        it { expect(subject).to eq [] }
      end

      context 'when args are defined' do
        let(:args) { '--color --format d' }

        it do
          expect(subject).to eq [
            '--color',
            '--format', 'd',
          ]
        end
      end
    end

    describe '#args_with_seed_option_added_when_viable' do
      subject { function_core.args_with_seed_option_added_when_viable(is_seed_used, seed, args) }

      context 'when the order option is not random' do
        let(:args) { ['--order', 'defined'] }
        let(:is_seed_used) { false }
        let(:seed) { nil }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--order', 'defined']
        end
      end

      ['random', 'rand'].each do |random_option_value|
        context "when the order option is `#{random_option_value}`" do
          let(:args) { ['--order', random_option_value] }

          context 'when the seed is not used' do
            let(:is_seed_used) { false }
            let(:seed) { '123' }

            it 'does not add the seed option to args' do
              expect(subject).to eq ['--order', random_option_value]
            end
          end

          context 'when the seed is used' do
            let(:is_seed_used) { true }
            let(:seed) { '123' }

            it 'adds the seed option to args' do
              expect(subject).to eq ['--order', random_option_value, '--seed', '123']
            end
          end
        end
      end

      context 'when the order option is `rand:123`' do
        let(:args) { ['--order', 'rand:123'] }
        let(:is_seed_used) { true }
        let(:seed) { '123' }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--order', 'rand:123']
        end
      end

      context 'when the order option is not set in args AND seed is used' do
        let(:args) { ['--format', 'documentation'] }
        let(:is_seed_used) { true }
        let(:seed) { '123' }

        it 'adds the seed option to args' do
          expect(subject).to eq ['--format', 'documentation', '--seed', '123']
        end
      end

      context 'when the order option is not set in args AND seed is not used' do
        let(:args) { ['--format', 'documentation'] }
        let(:is_seed_used) { false }
        let(:seed) { '123' }

        it 'does not add the seed option to args' do
          expect(subject).to eq ['--format', 'documentation']
        end
      end
    end

    describe '#ensure_args_have_default_formatter' do
      subject { function_core.ensure_args_have_default_formatter(args) }

      before do
        expect(KnapsackPro::Adapters::RSpecAdapter).to receive(:has_format_option?).with(args).and_call_original
      end

      context 'when has no format option' do
        let(:args) { ['--color', '--profile'] }

        it 'adds the progress formatter to args' do
          expect(subject).to eq ['--color', '--profile', '--format', 'progress']
        end
      end

      context 'when has format option' do
        let(:args) { ['--color', '--format', 'd'] }

        it 'returns args' do
          expect(subject).to eq ['--color', '--format', 'd']
        end
      end
    end

    describe '#args_with_default_options' do
      let(:args) { ['--color', '--format', 'documentation'] }
      let(:test_dir) { 'spec' }

      subject { function_core.args_with_default_options(args, test_dir) }

      it 'adds default formatters' do
        expect(subject).to eq [
          '--color',
          '--format', 'documentation',
          '--default-path', 'spec',
          '--format', 'KnapsackPro::Formatters::TimeTracker',
        ]
      end
    end

    describe '#log_rspec_command' do
      let(:args) { ['--format', 'documentation'] }
      let(:test_file_paths) { ['a_spec.rb', 'b_spec.rb'] }

      subject { function_core.log_rspec_command(args, test_file_paths, type) }

      context 'when logs the RSpec command for a subset of queue (a batch of tests fetched from the Queue API)' do
        let(:type) { :subset_queue }

        it 'logs the RSpec copy & paste command' do
          expect(logger).to receive(:info).with('To retry the last batch of tests fetched from the Queue API, please run the following command on your machine:')
          expect(logger).to receive(:info).with('bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"')

          subject
        end
      end

      context 'when logs the RSpec command after all tests fetched from the Queue API' do
        let(:type) { :end_of_queue }

        it 'logs the RSpec copy & paste command' do
          expect(logger).to receive(:info).with('To retry all the tests assigned to this CI node, please run the following command on your machine:')
          expect(logger).to receive(:info).with('bundle exec rspec --format documentation "a_spec.rb" "b_spec.rb"')

          subject
        end
      end

      describe '#log_fail_fast_limit_met' do
        subject { function_core.log_fail_fast_limit_met }

        it 'logs a warning' do
          expect(logger).to receive(:warn).with('Test execution has been canceled because the RSpec --fail-fast option is enabled. It can cause other CI nodes to run tests longer because they need to consume more tests from the Knapsack Pro Queue API.')

          subject
        end
      end
    end
  end

=begin
  xdescribe '.run' do
    let(:test_suite_token_rspec) { 'fake-token' }
    let(:queue_id) { 'fake-queue-id' }
    let(:test_dir) { 'fake-test-dir' }
    let(:runner) do
      instance_double(described_class, test_dir: test_dir)
    end

    subject { described_class.run(args) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:test_suite_token_rspec).and_return(test_suite_token_rspec)
      expect(KnapsackPro::Config::EnvGenerator).to receive(:set_queue_id).and_return(queue_id)

      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_TEST_SUITE_TOKEN', test_suite_token_rspec)
      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_QUEUE_RECORDING_ENABLED', 'true')
      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_QUEUE_ID', queue_id)

      expect(KnapsackPro::Config::Env).to receive(:set_test_runner_adapter).with(KnapsackPro::Adapters::RSpecAdapter)

      expect(described_class).to receive(:new).with(KnapsackPro::Adapters::RSpecAdapter).and_return(runner)
    end

    context 'when args provided' do
      context 'when format option is not provided' do
        let(:args) { '--example-arg example-value' }

        it 'uses default formatter progress' do
          expected_exitstatus = 0
          expected_accumulator = {
            status: :completed,
            exitstatus: expected_exitstatus
          }
          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: [
              '--example-arg', 'example-value',
              '--format', 'progress',
              '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
              '--format', 'KnapsackPro::Formatters::TimeTracker',
              '--default-path', 'fake-test-dir',
            ],
            exitstatus: 0,
            all_test_file_paths: [],
          }
          expect(described_class).to receive(:handle_signal!)
          expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

          expect(Kernel).to receive(:exit).with(expected_exitstatus)

          subject
        end
      end

      context 'when format option is provided as --format' do
        let(:args) { '--format documentation' }

        it 'uses provided format option instead of default formatter progress' do
          expected_exitstatus = 0
          expected_accumulator = {
            status: :completed,
            exitstatus: expected_exitstatus
          }
          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: [
              '--format', 'documentation',
              '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
              '--format', 'KnapsackPro::Formatters::TimeTracker',
              '--default-path', 'fake-test-dir',
            ],
            exitstatus: 0,
            all_test_file_paths: [],
          }
          expect(described_class).to receive(:handle_signal!)
          expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

          expect(Kernel).to receive(:exit).with(expected_exitstatus)

          subject
        end
      end

      context 'when format option is provided as -f' do
        let(:args) { '-f d' }

        it 'uses provided format option instead of default formatter progress' do
          expected_exitstatus = 0
          expected_accumulator = {
            status: :completed,
            exitstatus: expected_exitstatus
          }
          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: [
              '-f', 'd',
              '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
              '--format', 'KnapsackPro::Formatters::TimeTracker',
              '--default-path', 'fake-test-dir',
            ],
            exitstatus: 0,
            all_test_file_paths: [],
          }
          expect(described_class).to receive(:handle_signal!)
          expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

          expect(Kernel).to receive(:exit).with(expected_exitstatus)

          subject
        end
      end

      context 'when format option is provided without a delimiter' do
        let(:args) { '-fMyCustomFormatter' }

        it 'uses provided format option instead of default formatter progress' do
          expected_exitstatus = 0
          expected_accumulator = {
            status: :completed,
            exitstatus: expected_exitstatus
          }
          accumulator = {
            status: :next,
            runner: runner,
            can_initialize_queue: true,
            args: [
              '-fMyCustomFormatter',
              '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
              '--format', 'KnapsackPro::Formatters::TimeTracker',
              '--default-path', 'fake-test-dir',
            ],
            exitstatus: 0,
            all_test_file_paths: [],
          }
          expect(described_class).to receive(:handle_signal!)
          expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

          expect(Kernel).to receive(:exit).with(expected_exitstatus)

          subject
        end
      end

      context 'when RSpec split by test examples feature is enabled' do
        before do
          expect(KnapsackPro::Config::Env).to receive(:rspec_split_by_test_examples?).and_return(true)
          expect(KnapsackPro::Adapters::RSpecAdapter).to receive(:ensure_no_tag_option_when_rspec_split_by_test_examples_enabled!).and_call_original
        end

        context 'when tag option is provided' do
          let(:args) { '--tag example-value' }

          it do
            expect { subject }.to raise_error(/It is not allowed to use the RSpec tag option together with the RSpec split by test examples feature/)
          end
        end
      end
    end

    context 'when args not provided' do
      let(:args) { nil }

      it do
        expected_exitstatus = 0
        expected_accumulator = {
          status: :completed,
          exitstatus: expected_exitstatus
        }
        accumulator = {
          status: :next,
          runner: runner,
          can_initialize_queue: true,
          args: [
            '--format', 'progress',
            '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter',
            '--format', 'KnapsackPro::Formatters::TimeTracker',
            '--default-path', 'fake-test-dir',
          ],
          exitstatus: 0,
          all_test_file_paths: [],
        }
        expect(described_class).to receive(:handle_signal!)
        expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

        expect(Kernel).to receive(:exit).with(expected_exitstatus)

        subject
      end
    end
  end

  xdescribe '.run_tests' do
    let(:runner) { instance_double(described_class) }
    let(:can_initialize_queue) { double(:can_initialize_queue) }
    let(:args) { ['--no-color', '--default-path', 'fake-test-dir'] }
    let(:exitstatus) { double }
    let(:all_test_file_paths) { [] }
    let(:accumulator) do
      {
        runner: runner,
        can_initialize_queue: can_initialize_queue,
        args: args,
        exitstatus: exitstatus,
        all_test_file_paths: all_test_file_paths,
      }
    end

    subject { described_class.run_tests(accumulator) }

    before do
      expect(runner).to receive(:test_file_paths).with(can_initialize_queue: can_initialize_queue, executed_test_files: all_test_file_paths).and_return(test_file_paths)
    end

    context 'when test files exist' do
      let(:test_file_paths) { ['a_spec.rb', 'b_spec.rb'] }
      let(:logger) { double }
      let(:rspec_seed) { 7771 }
      let(:exit_code) { [0, 1].sample }
      let(:rspec_wants_to_quit) { false }
      let(:rspec_is_quitting) { false }
      let(:rspec_core_runner) do
        double(world: double(wants_to_quit: rspec_wants_to_quit, rspec_is_quitting: rspec_is_quitting))
      end

      context 'having no exception when running RSpec' do
        before do
          subset_queue_id = 'fake-subset-queue-id'
          expect(KnapsackPro::Config::EnvGenerator).to receive(:set_subset_queue_id).and_return(subset_queue_id)

          expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_SUBSET_QUEUE_ID', subset_queue_id)

          expect(described_class).to receive(:ensure_spec_opts_have_knapsack_pro_formatters)
          options = double
          expect(RSpec::Core::ConfigurationOptions).to receive(:new).with([
            '--no-color',
            '--default-path', 'fake-test-dir',
            'a_spec.rb', 'b_spec.rb',
          ]).and_return(options)

          expect(RSpec::Core::Runner).to receive(:new).with(options).and_return(rspec_core_runner)
          expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_return(exit_code)

          expect(described_class).to receive(:rspec_clear_examples)

          expect(KnapsackPro::Hooks::Queue).to receive(:call_before_subset_queue)

          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)

          configuration = double
          expect(rspec_core_runner).to receive(:configuration).twice.and_return(configuration)
          expect(configuration).to receive(:seed_used?).and_return(true)
          expect(configuration).to receive(:seed).and_return(rspec_seed)

          expect(KnapsackPro).to receive(:logger).at_least(2).and_return(logger)
          expect(logger).to receive(:info)
            .with("To retry the last batch of tests fetched from the API Queue, please run the following command on your machine:")
          expect(logger).to receive(:info).with(/#{args.join(' ')} --seed #{rspec_seed}/)
        end

        context 'when the exit code is zero' do
          let(:exit_code) { 0 }

          it do
            expect(subject).to eq({
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              all_test_file_paths: test_file_paths,
            })
          end
        end

        context 'when the exit code is not zero' do
          let(:exit_code) { double }

          it do
            expect(subject).to eq({
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exit_code,
              all_test_file_paths: test_file_paths,
            })
          end
        end

        context 'when RSpec wants to quit' do
          let(:exit_code) { 0 }
          let(:rspec_wants_to_quit) { true }

          after do
            described_class.class_variable_set(:@@terminate_process, false)
          end

          it 'terminates the process' do
            expect(logger).to receive(:warn).with('RSpec wants to quit.')

            expect(described_class.class_variable_get(:@@terminate_process)).to be false

            expect(subject).to eq({
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              all_test_file_paths: test_file_paths,
            })

            expect(described_class.class_variable_get(:@@terminate_process)).to be true
          end
        end

        context 'when RSpec is quitting' do
          let(:exit_code) { 0 }
          let(:rspec_is_quitting) { true }

          after do
            described_class.class_variable_set(:@@terminate_process, false)
          end

          it 'terminates the process' do
            expect(logger).to receive(:warn).with('RSpec is quitting.')

            expect(described_class.class_variable_get(:@@terminate_process)).to be false

            expect(subject).to eq({
              status: :next,
              runner: runner,
              can_initialize_queue: false,
              args: args,
              exitstatus: exitstatus,
              all_test_file_paths: test_file_paths,
            })

            expect(described_class.class_variable_get(:@@terminate_process)).to be true
          end
        end
      end

      context 'having exception when running RSpec' do
        before do
          subset_queue_id = 'fake-subset-queue-id'
          expect(KnapsackPro::Config::EnvGenerator).to receive(:set_subset_queue_id).and_return(subset_queue_id)

          expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_SUBSET_QUEUE_ID', subset_queue_id)

          expect(described_class).to receive(:ensure_spec_opts_have_knapsack_pro_formatters)
          options = double
          expect(RSpec::Core::ConfigurationOptions).to receive(:new).with([
            '--no-color',
            '--default-path', 'fake-test-dir',
            'a_spec.rb', 'b_spec.rb',
          ]).and_return(options)

          rspec_core_runner = double
          expect(RSpec::Core::Runner).to receive(:new).with(options).and_return(rspec_core_runner)
          expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_raise SystemExit
          expect(KnapsackPro::Hooks::Queue).to receive(:call_before_subset_queue)
          allow(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)
          allow(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)
          allow(KnapsackPro::Formatters::RSpecQueueSummaryFormatter).to receive(:print_exit_summary)
          expect(Kernel).to receive(:exit).with(1)
        end

        it 'does not call #rspec_clear_examples' do
          expect(described_class).not_to receive(:rspec_clear_examples)
          expect { subject }.to raise_error SystemExit
        end

        it 'logs the exception' do
          expect(KnapsackPro).to receive(:logger).once.and_return(logger)
          expect(logger).to receive(:error).with("Having exception when running RSpec: #<SystemExit: SystemExit>")
          expect { subject }.to raise_error SystemExit
        end

        it 'calls #print_exit_summary' do
          expect(KnapsackPro::Formatters::RSpecQueueSummaryFormatter).to receive(:print_exit_summary)
          expect { subject }.to raise_error SystemExit
        end

        it 'calls #call_after_subset_queue and #call_after_queue' do
          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)
          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)
          expect { subject }.to raise_error SystemExit
        end
      end
    end

    context "when test files don't exist" do
      let(:test_file_paths) { [] }

      context 'when all_test_file_paths exist' do
        let(:all_test_file_paths) { ['a_spec.rb'] }
        let(:logger) { double }

        before do
          described_class.class_variable_set(:@@used_seed, used_seed)

          expect(KnapsackPro).to receive(:logger).twice.and_return(logger)

          expect(KnapsackPro::Adapters::RSpecAdapter).to receive(:verify_bind_method_called)

          expect(KnapsackPro::Formatters::RSpecQueueSummaryFormatter).to receive(:print_summary)
          expect(KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension).to receive(:print_summary)

          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)

          time_tracker = instance_double(KnapsackPro::Formatters::TimeTracker)
          times = all_test_file_paths.map do |path|
            [{ path: path, time_execution: 1.0 }]
          end
          expect(time_tracker).to receive(:queue).and_return(times)
          expect(KnapsackPro::Formatters::TimeTrackerFetcher).to receive(:call).and_return(time_tracker)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api).with(times)

          expect(logger).to receive(:info)
            .with('To retry all the tests assigned to this CI node, please run the following command on your machine:')
          expect(logger).to receive(:info).with(logged_rspec_command_matcher)
        end

        context 'when @@used_seed has been set' do
          let(:used_seed) { '8333' }
          let(:logged_rspec_command_matcher) { /#{args.join(' ')} --seed #{used_seed} \"a_spec.rb"/ }

          it do
            expect(subject).to eq({
              status: :completed,
              exitstatus: exitstatus,
            })
          end
        end

        context 'when @@used_seed has not been set' do
          let(:used_seed) { nil }
          let(:logged_rspec_command_matcher) { /#{args.join(' ')} \"a_spec.rb"/ }

          it do
            expect(subject).to eq({
              status: :completed,
              exitstatus: exitstatus,
            })
          end
        end
      end

      context "when all_test_file_paths don't exist" do
        let(:all_test_file_paths) { [] }

        it do
          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)

          time_tracker = instance_double(KnapsackPro::Formatters::TimeTracker)
          times = all_test_file_paths.map do |path|
            [{ path: path, time_execution: 0.0 }]
          end
          expect(time_tracker).to receive(:queue).and_return(times)
          expect(KnapsackPro::Formatters::TimeTrackerFetcher).to receive(:call).and_return(time_tracker)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api).with(times)

          expect(KnapsackPro).to_not receive(:logger)

          expect(subject).to eq({
            status: :completed,
            exitstatus: exitstatus,
          })
        end
      end
    end
  end

=end
end
