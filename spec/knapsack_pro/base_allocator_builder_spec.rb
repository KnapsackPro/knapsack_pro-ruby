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

  describe '#test_files' do
    subject { allocator_builder.test_files }

    context 'when looking for test files on disk by default' do
      it do
        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        test_files = double
        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

        expect(subject).to eq test_files
      end
    end

    context 'when RSpec adapter and rspec split by test examples is enabled' do
      let(:adapter_class) { KnapsackPro::Adapters::RSpecAdapter }
      let(:test_files) { double(size: 1000) }
      let(:cmd) { 'bundle exec rake knapsack_pro:rspec_test_example_detector' }

      before do
        expect(KnapsackPro::Config::Env).to receive(:rspec_split_by_test_examples?).and_return(true)

        test_file_pattern = double
        expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

        expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

        expect(Kernel).to receive(:system).with(cmd).and_return(cmd_result)
      end

      context 'when rake task to detect RSpec test examples works' do
        let(:cmd_result) { true }
        let(:test_file_example_paths) { double }
        let(:logger) { instance_double(Logger) }

        before do
          rspec_test_example_detector = instance_double(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector)
          expect(KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector).to receive(:new).and_return(rspec_test_example_detector)
          expect(rspec_test_example_detector).to receive(:test_file_example_paths).and_return(test_file_example_paths)

          expect(KnapsackPro).to receive(:logger).at_least(1).and_return(logger)
        end

        context 'when up to 1000 test files detected on disk' do
          let(:test_files) { double(size: 1000) }

          it do
            expect(logger).to receive(:warn).with("Generating RSpec test examples JSON report to prepare your test suite to be split by test examples (by individual 'it's. Thanks to that a single test file can be split across parallel CI nodes). Analyzing 1000 test files.")

            expect(subject).to eq test_file_example_paths
          end
        end

        context 'when more than 1000 test files detected on disk' do
          let(:test_files) { double(size: 1001) }

          it do
            expect(logger).to receive(:warn).with("Generating RSpec test examples JSON report to prepare your test suite to be split by test examples (by individual 'it's. Thanks to that a single test file can be split across parallel CI nodes). Analyzing 1001 test files.")
            expect(logger).to receive(:warn).with('You have more than 1000 test files, it may take longer to generate test examples. Please wait...')

            expect(subject).to eq test_file_example_paths
          end
        end
      end

      context 'when rake task to detect RSpec test examples failed' do
        let(:cmd_result) { false }

        it do
          expect { subject }.to raise_error(RuntimeError, 'Could not generate JSON report for RSpec. Rake task failed when running bundle exec rake knapsack_pro:rspec_test_example_detector')
        end
      end
    end
  end
end
