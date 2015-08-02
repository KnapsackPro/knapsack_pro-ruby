module FakeMinitest
  class Test < ::Minitest::Test
    include KnapsackPro::Adapters::MinitestAdapter::BindTimeTrackerMinitestPlugin
  end
end

describe KnapsackPro::Adapters::MinitestAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'test/**/*_test.rb'
  end

  describe '.test_path' do
    class FakeUserTest
      def test_user_age; end

      # method provided by Minitest
      # it returns test method name
      def name
        :test_user_age
      end
    end

    let(:obj) { FakeUserTest.new }

    subject { described_class.test_path(obj) }

    before do
      parent_of_test_dir = File.expand_path('../../../', File.dirname(__FILE__))
      parent_of_test_dir_regexp = Regexp.new("^#{parent_of_test_dir}")
      described_class.class_variable_set(:@@parent_of_test_dir, parent_of_test_dir_regexp)
    end

    it { should eq './spec/knapsack_pro/adapters/minitest_adapter_spec.rb' }
  end

  describe 'BindTimeTrackerMinitestPlugin' do
    let(:tracker) { instance_double(KnapsackPro::Tracker) }

    subject { ::FakeMinitest::Test.new }

    before do
      allow(KnapsackPro).to receive(:tracker).and_return(tracker)
    end

    describe '#before_setup' do
      let(:file) { 'test/models/user_test.rb' }

      it do
        expect(described_class).to receive(:test_path).with(subject).and_return(file)
        expect(tracker).to receive(:current_test_path=).with(file)
        expect(tracker).to receive(:start_timer)

        subject.before_setup
      end
    end

    describe '#after_teardown' do
      it do
        expect(tracker).to receive(:stop_timer)

        subject.after_teardown
      end
    end
  end

  describe 'bind methods' do
    describe '#bind_time_tracker' do
      let(:logger) { instance_double(Logger) }
      let(:global_time) { 'Global time: 01m 05s' }

      it do
        expect(::Minitest::Test).to receive(:send).with(:include, KnapsackPro::Adapters::MinitestAdapter::BindTimeTrackerMinitestPlugin)

        expect(::Minitest).to receive(:after_run).and_yield

        expect(KnapsackPro::Presenter).to receive(:global_time).and_return(global_time)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:info).with(global_time)

        subject.bind_time_tracker
      end
    end

    describe '#bind_save_report' do
      it do
        expect(::Minitest).to receive(:after_run).and_yield

        expect(KnapsackPro::Report).to receive(:save)

        subject.bind_save_report
      end
    end
  end

  describe '#set_test_helper_path' do
    let(:adapter) { described_class.new }
    let(:test_helper_path) { '/code/project/test/test_helper.rb' }

    subject { adapter.set_test_helper_path(test_helper_path) }

    after do
      expect(described_class.class_variable_get(:@@parent_of_test_dir)).to eq '/code/project'
    end

    it { should eql '/code/project' }
  end
end
