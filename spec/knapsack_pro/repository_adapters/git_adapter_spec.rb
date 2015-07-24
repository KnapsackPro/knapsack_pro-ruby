describe KnapsackPro::RepositoryAdapters::GitAdapter do
  before do
    described_class.credentials.set = {
      git_working_dir: KnapsackPro.root + '/spec/fixtures/repositories/fake_git_repo'
    }
  end

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
