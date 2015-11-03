describe KnapsackPro::Adapters::CucumberAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'features/**{,/*/**}/*.feature'
  end

  context do
    before do
      allow(::Cucumber::RbSupport::RbDsl).to receive(:register_rb_hook)
      allow(Kernel).to receive(:at_exit)
    end

    it_behaves_like 'adapter'
  end

  describe '.test_path' do
    subject { described_class.test_path(scenario_or_outline_table) }

    context 'when scenario' do
      let(:scenario_file) { 'features/scenario.feature' }
      let(:scenario_or_outline_table) { double(file: scenario_file) }

      it { should eql scenario_file }
    end

    context 'when scenario outline' do
      let(:scenario_outline_file) { 'features/scenario_outline.feature' }
      let(:scenario_or_outline_table) do
        double(scenario_outline: double(file: scenario_outline_file))
      end

      it { should eql scenario_outline_file }
    end
  end

  describe 'bind methods' do
    describe '#bind_time_tracker' do
      let(:file) { 'features/a.feature' }
      let(:scenario) { double(file: file) }
      let(:block) { double }
      let(:tracker) { instance_double(KnapsackPro::Tracker) }
      let(:logger) { instance_double(Logger) }
      let(:global_time) { 'Global time: 01m 05s' }

      it do
        expect(subject).to receive(:Around).and_yield(scenario, block)
        allow(KnapsackPro).to receive(:tracker).and_return(tracker)
        expect(tracker).to receive(:current_test_path=).with(file)
        expect(tracker).to receive(:start_timer)
        expect(block).to receive(:call)
        expect(tracker).to receive(:stop_timer)

        expect(::Kernel).to receive(:at_exit).and_yield
        expect(KnapsackPro::Presenter).to receive(:global_time).and_return(global_time)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:info).with(global_time)

        subject.bind_time_tracker
      end
    end

    describe '#bind_save_report' do
      it do
        expect(::Kernel).to receive(:at_exit).and_yield

        expect(KnapsackPro::Report).to receive(:save)

        subject.bind_save_report
      end
    end
  end
end
