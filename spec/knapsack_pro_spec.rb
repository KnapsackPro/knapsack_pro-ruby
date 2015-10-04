describe KnapsackPro do
  describe '.root' do
    subject { described_class.root }

    it { expect(subject).to match 'knapsack' }
  end

  describe '.logger' do
    let(:logger_wrapper) { double }

    subject { described_class.logger }

    before { described_class.reset_logger! }
    after { described_class.reset_logger! }

    context 'when default logger' do
      let(:logger) { instance_double(Logger) }

      before do
        expect(Logger).to receive(:new).with(STDOUT).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::INFO)
        expect(KnapsackPro::LoggerWrapper).to receive(:new).with(logger).and_return(logger_wrapper)
      end

      it { should eql logger_wrapper }
    end

    context 'when custom logger' do
      let(:logger) { double('custom logger') }

      before do
        expect(KnapsackPro::LoggerWrapper).to receive(:new).with(logger).and_return(logger_wrapper)
        described_class.logger = logger
      end

      it { should eql logger_wrapper }
    end
  end

  describe '.tracker' do
    subject { described_class.tracker }

    it { should be_a KnapsackPro::Tracker }
    it { expect(subject.object_id).to eql described_class.tracker.object_id }
  end

  describe '.load_tasks' do
    let(:task_loader) { instance_double(KnapsackPro::TaskLoader) }

    it do
      expect(KnapsackPro::TaskLoader).to receive(:new).and_return(task_loader)
      expect(task_loader).to receive(:load_tasks)
      described_class.load_tasks
    end
  end
end
