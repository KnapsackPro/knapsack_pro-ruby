describe KnapsackPro::Adapters::BaseAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'test/**{,/*/**}/*_test.rb'
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
    let(:recording_enabled?) { false }
    let(:queue_recording_enabled?) { false }

    before do
      expect(KnapsackPro::Config::Env).to receive(:recording_enabled?).and_return(recording_enabled?)
      expect(KnapsackPro::Config::Env).to receive(:queue_recording_enabled?).and_return(queue_recording_enabled?)
    end

    after { subject.bind }

    context 'when recording enabled' do
      let(:recording_enabled?) { true }

      before do
        allow(subject).to receive(:bind_time_tracker)
        allow(subject).to receive(:bind_save_report)
      end

      it do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:debug).with('Test suite time execution recording enabled.')
      end
      it { expect(subject).to receive(:bind_time_tracker) }
      it { expect(subject).to receive(:bind_save_report) }
    end

    context 'when queue recording enabled' do
      let(:queue_recording_enabled?) { true }

      before do
        allow(subject).to receive(:bind_before_queue_hook)
        allow(subject).to receive(:bind_time_tracker)
        allow(subject).to receive(:bind_save_queue_report)
      end

      it do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:debug).with('Test suite time execution queue recording enabled.')
      end
      it { expect(subject).to receive(:bind_before_queue_hook) }
      it { expect(subject).to receive(:bind_time_tracker) }
      it { expect(subject).to receive(:bind_save_queue_report) }
    end

    context 'when recording disabled' do
      it { expect(subject).not_to receive(:bind_time_tracker) }
      it { expect(subject).not_to receive(:bind_save_report) }
      it { expect(subject).not_to receive(:bind_save_queue_report) }
      it { expect(subject).not_to receive(:bind_before_queue_hook) }
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

  describe '#bind_save_queue_report' do
    it do
      expect {
        subject.bind_save_queue_report
      }.to raise_error(NotImplementedError)
    end
  end

  describe '#bind_before_queue_hook' do
    it do
      expect {
        subject.bind_before_queue_hook
      }.to raise_error(NotImplementedError)
    end
  end
end
