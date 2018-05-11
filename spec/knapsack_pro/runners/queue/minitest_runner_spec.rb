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
    end

    context 'when args provided' do
      let(:args) { '--verbose --pride' }

      it do
        result = double
        expect(described_class).to receive(:run_tests).with(runner, true, ['--verbose', '--pride'], 0, []).and_return(result)

        expect(subject).to eq result
      end
    end

    context 'when args not provided' do
      let(:args) { nil }

      it do
        result = double
        expect(described_class).to receive(:run_tests).with(runner, true, [], 0, []).and_return(result)

        expect(subject).to eq result
      end
    end
  end
end
