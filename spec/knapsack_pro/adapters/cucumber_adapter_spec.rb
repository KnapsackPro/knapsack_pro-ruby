describe KnapsackPro::Adapters::CucumberAdapter do
  it do
    expect(described_class::TEST_DIR_PATTERN).to eq 'features/**{,/*/**}/*.feature'
  end

  context do
    context 'when Cucumber version 1' do
      before do
        stub_const('Cucumber::VERSION', '1.3.20')
        allow(::Cucumber::RbSupport::RbDsl).to receive(:register_rb_hook)
        allow(Kernel).to receive(:at_exit)
      end

      it_behaves_like 'adapter'
    end

    context 'when Cucumber version 2' do
      before do
        stub_const('Cucumber::VERSION', '2')
        allow(::Cucumber::RbSupport::RbDsl).to receive(:register_rb_hook)
        allow(Kernel).to receive(:at_exit)
      end

      it_behaves_like 'adapter'
    end

    context 'when Cucumber version 3' do
      before do
        stub_const('Cucumber::VERSION', '3.0.0')
        allow(::Cucumber::Glue::Dsl).to receive(:register_rb_hook)
        allow(Kernel).to receive(:at_exit)
      end

      it_behaves_like 'adapter'
    end
  end

  describe '.test_path' do
    context 'when Cucumber version 1' do
      subject { described_class.test_path(scenario_or_outline_table) }

      before { stub_const('Cucumber::VERSION', '1') }

      context 'when cucumber >= 1.3' do
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

      context 'when cucumber < 1.3' do
        context 'when scenario' do
          let(:scenario_file) { 'features/scenario.feature' }
          let(:scenario_or_outline_table) { double(feature: double(file: scenario_file)) }

          it { should eql scenario_file }
        end

        context 'when scenario outline' do
          let(:scenario_outline_file) { 'features/scenario_outline.feature' }
          let(:scenario_or_outline_table) do
            double(scenario_outline: double(feature: double(file: scenario_outline_file)))
          end

          it { should eql scenario_outline_file }
        end
      end
    end

    context 'when Cucumber version 2' do
      let(:file) { 'features/a.feature' }
      let(:test_case) { double(location: double(file: file)) } # Cucumber 2

      subject { described_class.test_path(test_case) }

      before { stub_const('Cucumber::VERSION', '2') }

      it { should eql file }
    end
  end

  describe '.split_by_test_cases_enabled?' do
    subject { described_class.split_by_test_cases_enabled? }

    before do
      expect(KnapsackPro::Config::Env).to receive(:cucumber_split_by_test_examples?).and_return(cucumber_split_by_test_examples_enabled)
    end

    context 'when the Cucumber split by test examples is enabled' do
      let(:cucumber_split_by_test_examples_enabled) { true }

      before { stub_const('Cucumber::VERSION', '4.1.0') }

      it { expect(subject).to be true }

      context 'when the Cucumber version is < 4.0' do
        before { stub_const('Cucumber::VERSION', '3.2.0') }

        it do
          expect { subject }.to raise_error RuntimeError, 'Cucumber >= 4.0 is required to split test files by test examples. Learn more: https://knapsackpro.com/perma/ruby/split-by-test-examples'
        end
      end
    end

    context 'when the Cucumber split by test examples is disabled' do
      let(:cucumber_split_by_test_examples_enabled) { false }

      it { expect(subject).to be false }
    end
  end

  describe '.calculate_slow_id_paths' do
    subject { described_class.calculate_slow_id_paths }

    before do
      cmd = 'RACK_ENV=test RAILS_ENV=test bundle exec rake knapsack_pro:cucumber_test_example_detector'
      expect(Kernel).to receive(:system).with(cmd).and_return(cmd_result)
    end

    context 'when the rake task to detect Cucumber test examples succeeded' do
      let(:cmd_result) { true }

      it 'returns test example paths for slow test files' do
        cucumber_test_example_detector = instance_double(KnapsackPro::TestCaseDetectors::CucumberTestExampleDetector)
        expect(KnapsackPro::TestCaseDetectors::CucumberTestExampleDetector).to receive(:new).and_return(cucumber_test_example_detector)

        slow_id_paths = double
        expect(cucumber_test_example_detector).to receive(:slow_id_paths!).and_return(slow_id_paths)

        expect(subject).to eq slow_id_paths
      end
    end

    context 'when the rake task to detect Cucumber test examples failed' do
      let(:cmd_result) { false }

      it do
        expect { subject }.to raise_error(RuntimeError, 'Failed to calculate Split by Test Examples: RACK_ENV=test RAILS_ENV=test bundle exec rake knapsack_pro:cucumber_test_example_detector')
      end
    end
  end

  describe '.parse_file_path' do
    subject { described_class.parse_file_path(path) }

    context 'when the path is a test example path' do
      let(:path) { 'features/a.feature:12' }

      it { is_expected.to eq 'features/a.feature' }
    end

    context 'when the path is a test file path' do
      let(:path) { 'features/a.feature' }

      it { is_expected.to eq 'features/a.feature' }
    end
  end

  describe '.id_path?' do
    subject { described_class.id_path?(path) }

    context 'when the path is a test example path' do
      let(:path) { 'features/a.feature:12' }

      it { is_expected.to be true }
    end

    context 'when the path is a test file path' do
      let(:path) { 'features/a.feature' }

      it { is_expected.to be false }
    end
  end

  describe '.concat_test_files' do
    let(:test_files) do
      [
        { 'path' => 'features/a.feature' },
        { 'path' => 'features/b.feature' },
        { 'path' => 'features/c.feature' },
        { 'path' => 'features/slow_1.feature' },
        { 'path' => 'features/slow_2.feature' },
      ]
    end

    let(:id_paths) do
      [
        'features/slow_1.feature:3',
        'features/slow_1.feature:12',
        'features/slow_2.feature:5',
        'features/slow_2.feature:14',
        'features/slow_2.feature:15',
      ]
    end

    subject { described_class.concat_test_files(test_files, id_paths) }

    it 'concats by replacing test_files with the associated id_paths' do
      expect(subject).to eq([
        { 'path' => 'features/a.feature' },
        { 'path' => 'features/b.feature' },
        { 'path' => 'features/c.feature' },
        { 'path' => 'features/slow_1.feature:3' },
        { 'path' => 'features/slow_1.feature:12' },
        { 'path' => 'features/slow_2.feature:5' },
        { 'path' => 'features/slow_2.feature:14' },
        { 'path' => 'features/slow_2.feature:15' },
      ])
    end
  end

  describe '.remove_formatters' do
    subject { described_class.remove_formatters(cli_args) }

    context 'when CLI args include formatters' do
      let(:cli_args) { ['--tags', 'not @slow', '-f', 'pretty', '-o', '/tmp/pretty.txt', '--format', 'json', '--out', '/tmp/file.json', '--strict'] }

      it 'removes formatters and the related output file options' do
        expect(subject).to eq ['--tags', 'not @slow', '--strict']
      end
    end
  end

  describe '.tracked_test_path' do
    let(:file) { 'features/a.feature' }
    let(:test_case) { double(location: double(file: file, line: 12)) }

    subject { described_class.tracked_test_path(test_case) }

    before { stub_const('Cucumber::VERSION', '4.1.0') }

    context 'when the split by test examples is disabled' do
      before do
        expect(described_class).to receive(:split_by_test_cases_enabled?).and_return(false)
      end

      it { is_expected.to eq file }
    end

    context 'when the split by test examples is enabled' do
      before do
        expect(described_class).to receive(:split_by_test_cases_enabled?).and_return(true)
        expect(KnapsackPro.tracker).to receive(:scheduled_test_path?).with('features/a.feature:12').and_return(scheduled)
      end

      context 'when the test example path is scheduled on this CI node (the test file was split by test examples)' do
        let(:scheduled) { true }

        it { is_expected.to eq 'features/a.feature:12' }
      end

      context 'when the test example path is not scheduled on this CI node (the test file was not split)' do
        let(:scheduled) { false }

        it { is_expected.to eq file }
      end
    end
  end

  describe 'bind methods' do
    describe '#bind_time_tracker' do
      let(:file) { 'features/a.feature' }
      let(:block) { double }
      let(:tracker) { instance_double(KnapsackPro::Tracker) }
      let(:logger) { instance_double(Logger) }
      let(:global_time) { 'Global time: 01m 05s' }

      context 'when Cucumber version 1' do
        let(:scenario) { double(file: file) }

        before { stub_const('Cucumber::VERSION', '1.3.20') }

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
          expect(logger).to receive(:debug).with(global_time)

          subject.bind_time_tracker
        end
      end

      context 'when Cucumber version 2' do
        let(:test_case) { double(location: double(file: file)) }

        # complex version name to ensure we can catch that too
        before { stub_const('Cucumber::VERSION', '2.0.0.rc.5') }

        it do
          expect(subject).to receive(:Around).and_yield(test_case, block)
          allow(KnapsackPro).to receive(:tracker).and_return(tracker)
          expect(tracker).to receive(:current_test_path=).with(file)
          expect(tracker).to receive(:start_timer)
          expect(block).to receive(:call)
          expect(tracker).to receive(:stop_timer)

          expect(::Kernel).to receive(:at_exit).and_yield
          expect(KnapsackPro::Presenter).to receive(:global_time).and_return(global_time)
          expect(KnapsackPro).to receive(:logger).and_return(logger)
          expect(logger).to receive(:debug).with(global_time)

          subject.bind_time_tracker
        end
      end
    end

    describe '#bind_save_report' do
      it do
        expect(::Kernel).to receive(:at_exit).and_yield

        expect(KnapsackPro::Report).to receive(:save)

        subject.bind_save_report
      end

      context 'when cucumber tests failed' do
        let(:exit_status) { double }
        let(:latest_error) { instance_double(SystemExit, status: exit_status) }

        it 'preserves cucumber latest error message exit status' do
          expect(::Kernel).to receive(:at_exit).and_yield

          expect(latest_error).to receive(:is_a?).with(SystemExit).and_return(true)
          expect(KnapsackPro::Report).to receive(:save)
          expect(::Kernel).to receive(:exit).with(exit_status)

          subject.bind_save_report(latest_error)
        end
      end
    end

    describe '#bind_before_queue_hook' do
      let(:block) { double }
      let(:scenario) { double(:scenario) }

      context 'when KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED is not set' do
        before { stub_const("ENV", {}) }

        it do
          expect(subject).to receive(:Around).and_yield(scenario, block)

          expect(KnapsackPro::Hooks::Queue).to receive(:call_before_queue)
          expect(ENV).to receive(:[]=).with('KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED', 'true')

          expect(block).to receive(:call)

          subject.bind_before_queue_hook
        end
      end

      context 'when KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED is set' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_BEFORE_QUEUE_HOOK_CALLED' => 'true' }) }

        it do
          expect(subject).to receive(:Around).and_yield(scenario, block)

          expect(KnapsackPro::Hooks::Queue).not_to receive(:call_before_queue)

          expect(block).to receive(:call)

          subject.bind_before_queue_hook
        end
      end
    end

    describe '#bind_after_queue_hook' do
      it do
        expect(::Kernel).to receive(:at_exit).and_yield
        expect(KnapsackPro::Hooks::Queue).to receive(:call_after_subset_queue)
        expect(KnapsackPro::Report).to receive(:save_subset_queue_to_file)

        subject.bind_after_queue_hook
      end
    end
  end
end
