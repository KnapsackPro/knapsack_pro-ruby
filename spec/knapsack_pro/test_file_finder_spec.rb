describe KnapsackPro::TestFileFinder do
  describe '.call' do
    let(:test_file_pattern) { double }
    let(:test_files) { double }

    subject { described_class.call(test_file_pattern) }

    before do
      test_file_finder = instance_double(described_class, call: test_files)
      expect(described_class).to receive(:new).with(test_file_pattern).and_return(test_file_finder)
    end

    it { should eq test_files }
  end

  describe '#call' do
    let(:test_file_pattern) { 'spec_fake/**{,/*/**}/*_spec.rb' }

    subject { described_class.new(test_file_pattern).call }

    context 'when KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN is not defined' do
      it do
        should eq([
          {
            'path' => 'spec_fake/controllers/users_controller_spec.rb',
          },
          {
            'path' => 'spec_fake/models/admin_spec.rb',
          },
          {
            'path' => 'spec_fake/models/user_spec.rb',
          },
        ])
      end
    end

    context 'when KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN is defined' do
      let(:test_file_exclude_pattern) { 'spec_fake/controllers/*_spec.rb' }

      before do
        stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN' => test_file_exclude_pattern })
      end

      it do
        should eq([
          {
            'path' => 'spec_fake/models/admin_spec.rb',
          },
          {
            'path' => 'spec_fake/models/user_spec.rb',
          },
        ])
      end
    end

    context 'when KNAPSACK_PRO_TEST_FILE_LIST is defined' do
      # added spaces next to comma to check space is removed later
      let(:test_file_list) { 'spec/bar_spec.rb,spec/foo_spec.rb, spec/time_helpers_spec.rb:10 , spec/time_helpers_spec.rb:38' }

      before do
        stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_LIST' => test_file_list })
      end

      it do
        expect(subject).to eq([
          {
            'path' => 'spec/bar_spec.rb',
          },
          {
            'path' => 'spec/foo_spec.rb',
          },
          {
            'path' => 'spec/time_helpers_spec.rb:10',
          },
          {
            'path' => 'spec/time_helpers_spec.rb:38',
          },
        ])
      end
    end
  end
end
