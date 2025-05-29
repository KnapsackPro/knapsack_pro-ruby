describe KnapsackPro::Runners::SpinachRunner do
  subject { described_class.new(KnapsackPro::Adapters::SpinachAdapter) }

  it { should be_kind_of KnapsackPro::Runners::BaseRunner }

  describe '.run' do
    let(:args) { '--custom-arg' }

    subject { described_class.run(args) }

    before do
      stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH' => 'spinach-token' })

      expect(KnapsackPro::Config::Env).to receive(:set_test_runner_adapter).with(KnapsackPro::Adapters::SpinachAdapter)

      expect(described_class).to receive(:new)
      .with(KnapsackPro::Adapters::SpinachAdapter).and_return(runner)
    end

    context 'when test files were returned by Knapsack Pro API' do
      let(:test_file_paths) { ['features/a.feature', 'features/b.feature'] }
      let(:stringify_test_file_paths) { test_file_paths.join(' ') }
      let(:test_dir) { 'fake-test-dir' }
      let(:runner) do
        instance_double(described_class,
                        test_dir: test_dir,
                        test_file_paths: test_file_paths,
                        stringify_test_file_paths: stringify_test_file_paths,
                        test_files_to_execute_exist?: true)
      end

      it do
        expect(KnapsackPro::Adapters::SpinachAdapter).to receive(:verify_bind_method_called)

        tracker = instance_double(KnapsackPro::Tracker)
        expect(KnapsackPro).to receive(:tracker).and_return(tracker)
        expect(tracker).to receive(:set_prerun_tests).with(test_file_paths)

        expect(Kernel).to receive(:exec).with('KNAPSACK_PRO_REGULAR_MODE_ENABLED=true KNAPSACK_PRO_TEST_SUITE_TOKEN=spinach-token bundle exec spinach --custom-arg --features_path fake-test-dir -- features/a.feature features/b.feature')

        subject
      end
    end

    context 'when test files were not returned by Knapsack Pro API' do
      let(:runner) do
        instance_double(described_class,
                        test_files_to_execute_exist?: false)
      end

      it "doesn't run tests" do
        subject
      end
    end
  end
end
