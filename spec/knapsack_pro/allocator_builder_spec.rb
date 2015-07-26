describe KnapsackPro::AllocatorBuilder do
  let(:adapter_class) { KnapsackPro::Adapters::BaseAdapter }
  let(:allocator_builder) { described_class.new(adapter_class) }

  describe '#allocator' do
    let(:allocator) { double }

    subject { allocator_builder.allocator }

    before do
      test_file_pattern = double
      expect(KnapsackPro::TestFilePattern).to receive(:call).with(adapter_class).and_return(test_file_pattern)

      test_files = double
      expect(KnapsackPro::TestFileFinder).to receive(:call).with(test_file_pattern).and_return(test_files)

      repository_adapter = double
      expect(KnapsackPro::RepositoryAdapterInitiator).to receive(:call).and_return(repository_adapter)

      ci_node_total = double
      expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(ci_node_total)
      ci_node_index = double
      expect(KnapsackPro::Config::Env).to receive(:ci_node_index).and_return(ci_node_index)

      expect(KnapsackPro::Allocator).to receive(:new).with({
        test_files: test_files,
        ci_node_total: ci_node_total,
        ci_node_index: ci_node_index,
        repository_adapter: repository_adapter,
      }).and_return(allocator)
    end

    it { should eq allocator }
  end

  describe '#test_dir' do
    subject { allocator_builder.test_dir }

    before do
      expect(KnapsackPro::TestFilePattern).to receive(:call).and_return('spec/**/*_spec.rb')
    end

    it { should eq 'spec' }
  end
end
