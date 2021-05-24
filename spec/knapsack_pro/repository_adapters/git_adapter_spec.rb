describe KnapsackPro::RepositoryAdapters::GitAdapter do
  let!(:circle_sha1) { ENV['CIRCLE_SHA1'] }
  let!(:circle_branch) { ENV['CIRCLE_BRANCH'] }

  it { should be_kind_of KnapsackPro::RepositoryAdapters::BaseAdapter }

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    context do
      before do
        stub_const('ENV', {
          'KNAPSACK_PRO_PROJECT_DIR' => KnapsackPro.root,
        })
      end

      it { should_not be_nil }
      its(:size) { should eq 40 }
    end

    it { should eq circle_sha1 } if ENV['CIRCLECI']
  end

  describe '#branch' do
    subject { described_class.new.branch }

    context do
      before do
        stub_const('ENV', {
          'KNAPSACK_PRO_PROJECT_DIR' => KnapsackPro.root,
        })
      end

      it { should_not be_nil }
    end

    it { should eq circle_branch } if ENV['CIRCLECI']
  end

  describe '#branches' do
    subject { described_class.new.branches }

    context do
      before do
        stub_const('ENV', {
          'KNAPSACK_PRO_PROJECT_DIR' => KnapsackPro.root,
        })
      end

      it { expect(subject.include?('master')).to be true }
    end

    it { expect(subject.include?(circle_branch)).to be true } if ENV['CIRCLECI']
  end
end
