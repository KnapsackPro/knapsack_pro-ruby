describe KnapsackPro::Runners::BaseRunner do
  let(:adapter_class) { double }
  let(:runner) do
    described_class.new(adapter_class)
  end
  let(:allocator) { instance_double(KnapsackPro::Allocator) }
  let(:allocator_builder) { instance_double(KnapsackPro::AllocatorBuilder) }

  before do
    expect(KnapsackPro::AllocatorBuilder).to receive(:new).with(adapter_class).and_return(allocator_builder)
    expect(allocator_builder).to receive(:allocator).and_return(allocator)
  end

  describe '#test_file_paths' do
    let(:test_file_paths) { double }

    subject { runner.test_file_paths }

    before do
      expect(allocator).to receive(:test_file_paths).and_return(test_file_paths)
    end

    it { should eq test_file_paths }
  end

  describe '#stringify_test_file_paths' do
    let(:stringify_test_file_paths) { double }

    subject { runner.stringify_test_file_paths }

    before do
      test_file_paths = double
      expect(runner).to receive(:test_file_paths).and_return(test_file_paths)
      expect(KnapsackPro::TestFilePresenter).to receive(:stringify_paths).with(test_file_paths).and_return(stringify_test_file_paths)
    end

    it { should eq stringify_test_file_paths }
  end

  describe '#test_dir' do
    let(:test_dir) { double }

    subject { runner.test_dir }

    before do
      expect(allocator_builder).to receive(:test_dir).and_return(test_dir)
    end

    it { should eq test_dir }
  end
end
