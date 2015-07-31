describe KnapsackPro::Adapters::BaseAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'test/**/*_test.rb'
  end

  describe '.bind' do
    let(:adapter) { instance_double(described_class) }

    subject { described_class.bind }

    before do
      expect(described_class).to receive(:new).and_return(adapter)
      expect(adapter).to receive(:bind)
    end

    it { should eql adapter }
  end

  describe '#bind' do
    before do
      expect(KnapsackPro::Config::Env).to receive(:recording_enabled?).and_return(recording_enabled?)
    end

    context 'when recording enabled' do
      let(:recording_enabled?) { true }

      it do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:info).with('[Knapsack Pro] Test suite time execution recording enabled.')
        expect(subject).to receive(:bind_time_tracker)
        expect(subject).to receive(:bind_save_report)
        subject.bind
      end
    end

    context 'when recording not enabled' do
      let(:recording_enabled?) { false }

      it do
        expect(subject).not_to receive(:bind_time_tracker)
        expect(subject).not_to receive(:bind_save_report)
        subject.bind
      end
    end
  end

  describe '#bind_time_tracker' do
    it do
      expect {
        subject.bind_time_tracker
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#bind_save_report' do
    it do
      expect {
        subject.bind_save_report
      }.to raise_error(NotImplementedError)
    end
  end
end
