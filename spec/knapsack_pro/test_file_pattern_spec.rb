describe KnapsackPro::TestFilePattern do
  describe '.call' do
    let(:adapter_class) { KnapsackPro::Adapters::BaseAdapter }

    subject { described_class.call(adapter_class) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:test_file_pattern).and_return(env_test_file_pattern)
    end

    context 'when ENV defined' do
      let(:env_test_file_pattern) { 'spec/**/*_spec.rb' }

      it { should eq env_test_file_pattern }
    end

    context 'when ENV not defined' do
      let(:env_test_file_pattern) { nil }

      it { should eq 'test/**/*_test.rb' }
    end
  end
end
