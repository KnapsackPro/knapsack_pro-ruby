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

    context 'when looking for test files on disk by default' do
      it do
        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        test_files = double
        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

        expect(subject).to eq test_files
      end
    end

    context 'when RSpec adapter AND rspec split by test examples is enabled' do
      let(:adapter_class) { KnapsackPro::Adapters::RSpecAdapter }
      let(:test_files_to_run) { double }
      let(:cmd) { 'RACK_ENV=test RAILS_ENV=test bundle exec rake knapsack_pro:rspec_test_example_detector' }

      before do
        expect(KnapsackPro::Config::Env).to receive(:rspec_split_by_test_examples?).and_return(true)

        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files_to_run)
      end

      context 'when RSpec version < 3.3.0' do
        before do
          stub_const('RSpec::Core::Version::STRING', '3.2.0')
        end

        it do
          expect { subject }.to raise_error RuntimeError, 'RSpec >= 3.3.0 is required to split test files by test examples. Learn more: https://github.com/KnapsackPro/knapsack_pro-ruby#split-test-files-by-test-cases'
        end
      end

      context 'when rake task to detect RSpec test examples works' do
        let(:slow_test_files) { double(size: 5) }
        let(:cmd_result) { true }
        let(:test_file_example_paths) { double }
        let(:logger) { instance_double(Logger) }
        let(:test_files_with_test_cases) { double }

        before do
          expect(allocator_builder).to receive(:get_slow_test_files).and_return(slow_test_files)

          expect(KnapsackPro).to receive(:logger).and_return(logger)

          expect(Kernel).to receive(:system).with(cmd).and_return(cmd_result)

          rspec_test_example_detector = instance_double(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector)
          expect(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector).to receive(:new).and_return(rspec_test_example_detector)
          expect(rspec_test_example_detector).to receive(:test_file_example_paths).and_return(test_file_example_paths)

          expect(KnapsackPro::TestFilesWithTestCasesComposer).to receive(:call).with(test_files_to_run, slow_test_files, test_file_example_paths).and_return(test_files_with_test_cases)
        end

        it do
          expect(logger).to receive(:info).with("Generating RSpec test examples JSON report for slow test files to prepare it to be split by test examples (by individual 'it's. Thanks to that a single slow test file can be split across parallel CI nodes). Analyzing 5 slow test files.")

          expect(subject).to eq test_files_with_test_cases
        end
      end

      context 'when rake task to detect RSpec test examples failed' do
        let(:slow_test_files) { double(size: 5) }
        let(:cmd_result) { false }

        before do
          expect(allocator_builder).to receive(:get_slow_test_files).and_return(slow_test_files)

          expect(Kernel).to receive(:system).with(cmd).and_return(cmd_result)
        end

        it do
          expect { subject }.to raise_error(RuntimeError, 'Could not generate JSON report for RSpec. Rake task failed when running RACK_ENV=test RAILS_ENV=test bundle exec rake knapsack_pro:rspec_test_example_detector')
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
