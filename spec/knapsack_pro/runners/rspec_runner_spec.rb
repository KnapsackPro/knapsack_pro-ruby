describe KnapsackPro::Runners::RSpecRunner do
  describe '.run' do
    let(:args) { '--profile --color' }

    subject { described_class.run(args) }

    it do
      allocator = instance_double(KnapsackPro::Allocator, test_file_paths: double)
      allocator_builder = instance_double(KnapsackPro::AllocatorBuilder,
                                          test_dir: 'fake_spec_dir',
                                          allocator: allocator)
      expect(KnapsackPro::AllocatorBuilder).to receive(:new)
      .with(KnapsackPro::Adapters::RSpecAdapter)
      .and_return(allocator_builder)

      expect(KnapsackPro::TestFilePresenter).to receive(:stringify_paths)
      .with(allocator.test_file_paths)
      .and_return('fake_spec_dir/a_spec.rb fake_spec_dir/b_spec.rb')

      expect(Kernel).to receive(:system)
      .with('KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec --profile --color --default-path fake_spec_dir -- fake_spec_dir/a_spec.rb fake_spec_dir/b_spec.rb')
      expect(Kernel).to receive(:exit)

      subject
    end
  end
end
