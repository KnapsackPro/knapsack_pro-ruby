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
end
