describe KnapsackPro::BaseAllocatorBuilder do
  let(:adapter_class) { KnapsackPro::Adapters::BaseAdapter }
  let(:allocator_builder) { described_class.new(adapter_class) }

  describe 'initialize method' do
    context 'when unknown adapter (base adapter)' do
      let(:adapter_class) { KnapsackPro::Adapters::BaseAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to be_nil
      end
    end

    context 'when RSpec adapter' do
      let(:adapter_class) { KnapsackPro::Adapters::RSpecAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to eq 'rspec'
      end
    end

    context 'when Cucumber adapter' do
      let(:adapter_class) { KnapsackPro::Adapters::CucumberAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to eq 'cucumber'
      end
    end

    context 'when Minitest adapter' do
      let(:adapter_class) { KnapsackPro::Adapters::MinitestAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to eq 'minitest'
      end
    end

    context 'when Spinach adapter' do
      let(:adapter_class) { KnapsackPro::Adapters::SpinachAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to eq 'spinach'
      end
    end

    context 'when Test::Unit adapter' do
      let(:adapter_class) { KnapsackPro::Adapters::TestUnitAdapter }

      it do
        allocator_builder
        expect(ENV['KNAPSACK_PRO_TEST_RUNNER']).to eq 'test-unit'
      end
    end
  end

  describe '#allocator' do
    subject { allocator_builder.allocator }

    it do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#test_dir' do
    subject { allocator_builder.test_dir }

    before do
      expect(KnapsackPro::Config::Env).to receive(:test_dir).and_return(test_dir)
    end

    context 'when test_dir is defined in ENV' do
      let(:test_dir) { double }

      it { should eq test_dir }
    end

    context 'when test_dir is not defined in ENV' do
      let(:test_dir) { nil }

      before do
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)
      end

      context 'when single pattern' do
        let(:test_file_pattern) { 'spec/**{,/*/**}/*_spec.rb' }

        it { should eq 'spec' }
      end

      context 'when multiple patterns' do
        let(:test_file_pattern) { '{spec/controllers/**/*.rb,spec/decorators/**/*.rb}' }

        it { should eq 'spec' }
      end
    end
  end

  describe '#fallback_mode_test_files' do
    subject { allocator_builder.fallback_mode_test_files }

    it do
      test_file_pattern = double
      expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

      test_files = double
      expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

      expect(subject).to eq test_files
    end
  end

  describe '#fast_and_slow_test_files_to_run' do
    subject { allocator_builder.fast_and_slow_test_files_to_run }

    context 'when split by test cases disabled' do
      it 'returns test files to run based on test files on the disk' do
        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        test_files = double
        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

        expect(subject).to eq test_files
      end
    end

    context 'when split by test cases enabled AND less than 2 CI nodes' do
      let(:test_files_to_run) { double }

      before  do
        expect(adapter_class).to receive(:split_by_test_cases_enabled?).and_return(true)

        expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(1)

        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files_to_run)
      end

      it 'returns test files without test cases' do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:warn).with('Skipping split of test files by test cases because you are running tests on a single CI node (no parallelism)')
        expect(subject).to eq test_files_to_run
      end
    end

    context 'when split by test cases enabled AND at least 2 CI nodes' do
      let(:test_files_to_run) { double }

      before  do
        expect(adapter_class).to receive(:split_by_test_cases_enabled?).and_return(true)

        expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(2)

        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files_to_run)

        expect(allocator_builder).to receive(:get_slow_test_files).and_return(slow_test_files)
      end

      context 'when slow test files are detected' do
        let(:slow_test_files) do
          [
            '1_spec.rb',
            '2_spec.rb',
          ]
        end

        it 'returns test files with test cases' do
          test_file_cases = double
          expect(adapter_class).to receive(:test_file_cases_for).with(slow_test_files).and_return(test_file_cases)

          test_files_with_test_cases = double
          expect(KnapsackPro::TestFilesWithTestCasesComposer).to receive(:call).with(test_files_to_run, slow_test_files, test_file_cases).and_return(test_files_with_test_cases)

          expect(subject).to eq test_files_with_test_cases
        end
      end

      context 'when slow test files are not detected' do
        let(:slow_test_files) { [] }

        it 'returns test files without test cases' do
          expect(subject).to eq test_files_to_run
        end
      end
    end
  end

  describe 'private #get_slow_test_files' do
    subject { allocator_builder.send(:get_slow_test_files) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:slow_test_file_pattern).and_return(slow_test_file_pattern)
    end

    context 'when slow test file pattern is present' do
      let(:slow_test_files) { double(:slow_test_files_based_on_pattern, size: 3) }
      let(:slow_test_file_pattern) { double }

      before do
        expect(KnapsackPro::TestFileFinder).to receive(:slow_test_files_by_pattern).with(adapter_class).and_return(slow_test_files)
      end

      it { expect(subject).to eq slow_test_files }
    end

    context 'when slow test file pattern is not present' do
      let(:slow_test_files) { double(:slow_test_files_based_on_api, size: 2) }
      let(:slow_test_file_pattern) { nil }

      before do
        expect(KnapsackPro::SlowTestFileFinder).to receive(:call).with(adapter_class).and_return(slow_test_files)
      end

      it { expect(subject).to eq slow_test_files }
    end
  end
end
