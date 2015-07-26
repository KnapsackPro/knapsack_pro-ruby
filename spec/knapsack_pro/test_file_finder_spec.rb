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
    let(:test_file_pattern) { 'spec_fake/**/*_spec.rb' }

    subject { described_class.new(test_file_pattern).call }

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
end
