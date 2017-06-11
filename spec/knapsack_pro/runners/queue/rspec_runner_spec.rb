describe KnapsackPro::Runners::Queue::RSpecRunner do
  before do
    # we don't want to modify rspec formatters because we want to see tests summary at the end
    # when you run this test file or whole test suite for the knapsack_pro gem
    stub_const('ENV', { 'KNAPSACK_PRO_MODIFY_DEFAULT_RSPEC_FORMATTERS' => false })

    require KnapsackPro.root + '/lib/knapsack_pro/formatters/rspec_queue_summary_formatter'
    require KnapsackPro.root + '/lib/knapsack_pro/formatters/rspec_queue_profile_formatter_extension'
  end

  describe '.run' do
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

      expect(described_class).to receive(:new).with(KnapsackPro::Adapters::RSpecAdapter).and_return(runner)
    end

    context 'when args provided' do
      context 'when format param is not provided' do
        let(:args) { '--example-arg example-value' }

        it 'uses default formatter progress' do
          result = double
          expect(described_class).to receive(:run_tests).with(runner, true, ['--example-arg', 'example-value', '--format', 'progress', '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter', '--default-path', 'fake-test-dir'], 0, []).and_return(result)

          expect(subject).to eq result
        end
      end

      context 'when format param is provided' do
        let(:args) { '--format documentation' }

        it 'uses provided format param instead of default formatter progress' do
          result = double
          expect(described_class).to receive(:run_tests).with(runner, true, ['--format', 'documentation', '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter', '--default-path', 'fake-test-dir'], 0, []).and_return(result)

          expect(subject).to eq result
        end
      end
    end

    context 'when args not provided' do
      let(:args) { nil }

      it do
        result = double
        expect(described_class).to receive(:run_tests).with(runner, true, ['--format', 'progress', '--format', 'KnapsackPro::Formatters::RSpecQueueSummaryFormatter', '--default-path', 'fake-test-dir'], 0, []).and_return(result)

        expect(subject).to eq result
      end
    end
  end

  describe '.run_tests' do
    let(:runner) { instance_double(described_class) }
    let(:can_initialize_queue) { double(:can_initialize_queue) }
    let(:args) { ['--example-arg', 'example-value', '--default-path', 'fake-test-dir'] }
    let(:exitstatus) { double }

    subject { described_class.run_tests(runner, can_initialize_queue, args, exitstatus, []) }

    before do
      expect(runner).to receive(:test_file_paths).with(can_initialize_queue: can_initialize_queue).and_return(test_file_paths)
    end

    context 'when test files exist' do
      let(:test_file_paths) { ['a_spec.rb', 'b_spec.rb'] }

      before do
        subset_queue_id = 'fake-subset-queue-id'
        expect(KnapsackPro::Config::EnvGenerator).to receive(:set_subset_queue_id).and_return(subset_queue_id)

        expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_SUBSET_QUEUE_ID', subset_queue_id)

        options = double
        expect(RSpec::Core::ConfigurationOptions).to receive(:new).with([
          '--example-arg', 'example-value',
          '--default-path', 'fake-test-dir',
          'a_spec.rb', 'b_spec.rb',
        ]).and_return(options)

        rspec_core_runner = double
        expect(RSpec::Core::Runner).to receive(:new).with(options).and_return(rspec_core_runner)
        expect(rspec_core_runner).to receive(:run).with($stderr, $stdout).and_return(exit_code)

        expect(described_class).to receive(:rspec_clear_examples)

        expect(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)

        # second call of run_tests because of recursion
        expect(runner).to receive(:test_file_paths).with(can_initialize_queue: false).and_return([])
      end

      context 'when exit code is zero' do
        let(:exit_code) { 0 }

        it do
          expect(KnapsackPro::Formatters::RSpecQueueSummaryFormatter).to receive(:print_summary)
          expect(KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension).to receive(:print_summary)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
          expect(described_class).to receive(:exit).with(exitstatus)

          subject
        end
      end

      context 'when exit code is not zero' do
        let(:exit_code) { double }

        it do
          expect(KnapsackPro::Formatters::RSpecQueueSummaryFormatter).to receive(:print_summary)
          expect(KnapsackPro::Formatters::RSpecQueueProfileFormatterExtension).to receive(:print_summary)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
          expect(described_class).to receive(:exit).with(exit_code)

          subject
        end
      end
    end

    context "when test files don't exist" do
      let(:test_file_paths) { [] }

      it do
        expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
        expect(described_class).to receive(:exit).with(exitstatus)

        subject
      end
    end
  end
end
