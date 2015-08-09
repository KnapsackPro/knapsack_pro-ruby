describe KnapsackPro::Runners::RSpecRunner do
  subject { described_class.new(KnapsackPro::Adapters::RSpecAdapter) }

  it { should be_kind_of KnapsackPro::Runners::BaseRunner }

  describe '.run' do
    let(:args) { '--profile --color' }

    after { described_class.run(args) }

    it do
      stringify_test_file_paths = 'spec/a_spec.rb spec/b_spec.rb'
      runner = instance_double(described_class,
                               test_dir: 'spec',
                               stringify_test_file_paths: stringify_test_file_paths)
      expect(described_class).to receive(:new)
      .with(KnapsackPro::Adapters::RSpecAdapter).and_return(runner)

      expect(Kernel).to receive(:exit)
      expect(Kernel).to receive(:system)
      .with('KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec --profile --color --default-path spec -- spec/a_spec.rb spec/b_spec.rb')
    end
  end
end
