describe KnapsackPro::RepositoryAdapters::GitAdapter do
  before do
    described_class.credentials.set = {
      git_working_dir: KnapsackPro.root + '/spec/fixtures/repositories/fake_git_repo'
    }
  end

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    it { should eq 'd2566533ed58eae18870cbd0454ee57b938b40f4' }
  end

  describe '#branch' do
    subject { described_class.new.branch }

    it { should eq 'new-feature' }
  end
end
