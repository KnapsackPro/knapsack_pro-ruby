require(KnapsackPro.root + '/lib/knapsack_pro/formatters/time_tracker')

describe KnapsackPro::Formatters::TimeTrackerFetcher do
  describe '.unexecuted_test_paths' do
    subject { described_class.unexecuted_test_paths }

    context 'when the time tracker formatter not found' do
      it do
        expect(subject).to eq []
      end
    end

    context 'when the time tracker formatter is found' do
      let(:time_tracker) { instance_double(KnapsackPro::Formatters::TimeTracker) }
      let(:unexecuted_test_paths) { double(:unexecuted_test_paths) }

      before do
        expect(described_class).to receive(:call).and_return(time_tracker)
        expect(time_tracker).to receive(:unexecuted_test_paths).and_return(unexecuted_test_paths)
      end

      it do
        expect(subject).to eq unexecuted_test_paths
      end
    end
  end
end
