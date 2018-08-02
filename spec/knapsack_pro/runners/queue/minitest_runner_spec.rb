describe KnapsackPro::Runners::Queue::MinitestRunner do
  describe '.run' do
    let(:test_suite_token_minitest) { 'fake-token' }
    let(:queue_id) { 'fake-queue-id' }
    let(:test_dir) { 'fake-test-dir' }
    let(:runner) do
      instance_double(described_class, test_dir: test_dir)
    end

    subject { described_class.run(args) }

    before do
      expect(described_class).to receive(:require).with('minitest')

      expect(KnapsackPro::Config::Env).to receive(:test_suite_token_minitest).and_return(test_suite_token_minitest)
      expect(KnapsackPro::Config::EnvGenerator).to receive(:set_queue_id).and_return(queue_id)

      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_TEST_SUITE_TOKEN', test_suite_token_minitest)
      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_QUEUE_RECORDING_ENABLED', 'true')
      expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_QUEUE_ID', queue_id)

      expect(described_class).to receive(:new).with(KnapsackPro::Adapters::MinitestAdapter).and_return(runner)

      expect($LOAD_PATH).to receive(:unshift).with(test_dir)
    end

    context 'when args provided' do
      let(:args) { '--verbose --pride' }

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
          args: ['--verbose', '--pride'],
          exitstatus: 0,
          all_test_file_paths: [],
        }
        expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

        expect(Kernel).to receive(:exit).with(expected_exitstatus)

        subject
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
          args: [],
          exitstatus: 0,
          all_test_file_paths: [],
        }
        expect(described_class).to receive(:run_tests).with(accumulator).and_return(expected_accumulator)

        expect(Kernel).to receive(:exit).with(expected_exitstatus)

        subject
      end
    end
  end

  describe '.run_tests' do
    let(:runner) { instance_double(described_class) }
    let(:can_initialize_queue) { double(:can_initialize_queue) }
    let(:args) { ['--verbose', '--pride'] }
    let(:exitstatus) { 0 }

    subject { described_class.run_tests(runner, can_initialize_queue, args, exitstatus, []) }

    before do
      expect(runner).to receive(:test_file_paths).with(can_initialize_queue: can_initialize_queue, executed_test_files: []).and_return(test_file_paths)
    end

    context 'when test files exist' do
      let(:test_file_paths) { ['a_test.rb', 'b_test.rb'] }

      before do
        subset_queue_id = 'fake-subset-queue-id'
        expect(KnapsackPro::Config::EnvGenerator).to receive(:set_subset_queue_id).and_return(subset_queue_id)

        expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_SUBSET_QUEUE_ID', subset_queue_id)

        expect(KnapsackPro).to receive_message_chain(:tracker, :reset!)

        # .minitest_run
        expect(described_class).to receive(:require).with('./a_test.rb')
        expect(described_class).to receive(:require).with('./b_test.rb')

        expect(Minitest).to receive(:run).with(args).and_return(is_tests_green)

        expect(Minitest::Runnable).to receive(:reset)


        expect(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)

        expect(KnapsackPro::Report).to receive(:save_subset_queue_to_file)

        # second call of run_tests because of recursion
        expect(runner).to receive(:test_file_paths).with(can_initialize_queue: false, executed_test_files: ['a_test.rb', 'b_test.rb']).and_return([])
      end

      context 'when tests are passing' do
        let(:is_tests_green) { true }

        it 'returns exit code 0' do
          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
          expect(described_class).to receive(:exit).with(0)

          subject
        end
      end

      context 'when tests are failing' do
        let(:is_tests_green) { false }

        it 'returns exit code 1' do
          expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)
          expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
          expect(described_class).to receive(:exit).with(1)

          subject
        end
      end
    end

    context "when test files don't exist" do
      let(:test_file_paths) { [] }

      it 'returns exit code 0' do
        expect(KnapsackPro::Hooks::Queue).to receive(:call_after_queue)
        expect(KnapsackPro::Report).to receive(:save_node_queue_to_api)
        expect(described_class).to receive(:exit).with(0)

        subject
      end
    end
  end
end
