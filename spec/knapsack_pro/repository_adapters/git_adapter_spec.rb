describe KnapsackPro::RepositoryAdapters::GitAdapter do
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
    it { should eq ENV['CIRCLE_SHA1'] } if ENV['CIRCLE_SHA1']
  end

  describe '#branch' do
    subject { described_class.new.branch }

    it { should_not be_nil }
    it { should eq ENV['CIRCLE_BRANCH'] } if ENV['CIRCLE_BRANCH']
  end
end
