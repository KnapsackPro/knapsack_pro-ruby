describe KnapsackPro::Runners::MinitestRunner do
  subject { described_class.new(KnapsackPro::Adapters::MinitestAdapter) }

  it { should be_kind_of KnapsackPro::Runners::BaseRunner }

  describe '.run' do
    let(:args) { '--custom-arg' }
    let(:task_name) { 'knapsack_pro:minitest_run' }

    subject { described_class.run(args) }

    it do
      test_file_paths = ['test_fake/a_test.rb', 'test_fake/b_test.rb']
      runner = instance_double(described_class,
                               test_dir: 'test',
                               test_file_paths: test_file_paths)
      expect(described_class).to receive(:new)
      .with(KnapsackPro::Adapters::MinitestAdapter).and_return(runner)

      expect(Rake::Task.task_defined?(task_name)).to be false

      subject

      expect(Rake::Task.task_defined?(task_name)).to be true
    end
  end
end
