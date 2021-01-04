describe KnapsackPro::Runners::SpinachRunner do
  subject { described_class.new(KnapsackPro::Adapters::SpinachAdapter) }

  it { should be_kind_of KnapsackPro::Runners::BaseRunner }

  describe '.run' do
    let(:args) { '--custom-arg' }

    subject { described_class.run(args) }

    before do
      stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH' => 'spinach-token' })

      expect(described_class).to receive(:new)
      .with(KnapsackPro::Adapters::SpinachAdapter).and_return(runner)
    end

    context 'when test files were returned by Knapsack Pro API' do
      let(:stringify_test_file_paths) { 'features/a.feature features/b.feature' }
      let(:test_dir) { 'fake-test-dir' }
      let(:runner) do
        instance_double(described_class,
                        test_dir: test_dir,
                        stringify_test_file_paths: stringify_test_file_paths,
                        test_files_to_execute_exist?: true)
      end

      before do
        expect(KnapsackPro::Adapters::SpinachAdapter).to receive(:verify_bind_method_called)

        expect(Kernel).to receive(:system).with('KNAPSACK_PRO_RECORDING_ENABLED=true KNAPSACK_PRO_TEST_SUITE_TOKEN=spinach-token bundle exec spinach --custom-arg --features_path fake-test-dir -- features/a.feature features/b.feature')
      end

      after { subject }

      context 'when command exit with success code' do
        let(:exitstatus) { 0 }

        before do
          expect($?).to receive(:exitstatus).and_return(exitstatus)
        end

        it do
          expect(Kernel).not_to receive(:exit)
        end
      end

      context 'when command exit without success code' do
        let(:exitstatus) { 1 }

        before do
          expect($?).to receive(:exitstatus).twice.and_return(exitstatus)
        end

        it do
          expect(Kernel).to receive(:exit).with(exitstatus)
        end
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
