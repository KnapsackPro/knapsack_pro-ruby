describe KnapsackPro::RepositoryAdapters::GitAdapter do
  let!(:circle_sha1) { ENV['CIRCLE_SHA1'] }
  let!(:circle_branch) { ENV['CIRCLE_BRANCH'] }

  before do
    stub_const('ENV', {
      'KNAPSACK_PRO_PROJECT_DIR' => KnapsackPro.root,
    })
  end

  it { should be_kind_of KnapsackPro::RepositoryAdapters::BaseAdapter }

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    it { should_not be_nil }
    its(:size) { should eq 40 }
    it { should eq circle_sha1 } if ENV['CIRCLE_SHA1']
  end

  describe '#branch' do
    subject { described_class.new.branch }

    it { should_not be_nil }
    it { should eq circle_branch } if ENV['CIRCLE_BRANCH']
  end

  describe '#branches' do
    subject { described_class.new.branches }

    it { expect(subject.include?('master')).to be true }
    it { expect(subject.include?(circle_branch)).to be true } if ENV['CIRCLE_BRANCH']
  end
end
