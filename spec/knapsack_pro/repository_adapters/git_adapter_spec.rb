describe KnapsackPro::RepositoryAdapters::GitAdapter do
  before do
    stub_const('ENV', {
      'KNAPSACK_PRO_PROJECT_DIR' => KnapsackPro.root,
    })
  end

  it { should be_kind_of KnapsackPro::RepositoryAdapters::BaseAdapter }

  describe '#commit_hash' do
    it 'returns the git commit hash' do
      adapter = described_class.new
      allow(adapter).to receive(:git_commit_hash).and_return('git-commit-hash')

      expect(adapter.commit_hash).to eq 'git-commit-hash'
    end

    context 'when KNAPSACK_PRO_COMMIT_HASH is set' do
      before do
        stub_const('ENV', { 'KNAPSACK_PRO_COMMIT_HASH' => 'custom-commit-hash' })
      end

      it 'returns KNAPSACK_PRO_COMMIT_HASH' do
        expect(described_class.new.commit_hash).to eq 'custom-commit-hash'
      end
    end
  end

  describe '#branch' do
    it 'returns the git branch' do
      adapter = described_class.new
      allow(adapter).to receive(:git_branch).and_return('git-branch')

      expect(adapter.branch).to eq 'git-branch'
    end

    context 'when KNAPSACK_PRO_BRANCH is set' do
      before do
        stub_const('ENV', { 'KNAPSACK_PRO_BRANCH' => 'custom-branch' })
      end

      it 'returns KNAPSACK_PRO_BRANCH without invoking git' do
        expect(described_class.new.branch).to eq 'custom-branch'
      end
    end
  end

  describe '#branches' do
    subject { described_class.new.branches }

    it { expect(subject.include?('main')).to be true }
  end

  describe '#build_author' do
    it "returns the masked build author" do
      allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_build_author).and_return(
        "John Doe <john.doe@example.com>" + "\n"
      )

      subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

      expect(subject.build_author).to eq 'Jo** Do* <jo**.do*@ex*****.co*>'
    end

    context "when the command raises an exception" do
      it "returns the no-git author" do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_build_author).and_raise(Exception)

        subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

        expect(subject.build_author).to eq "no git <no.git@example.com>"
      end
    end

    context "when the command returns an empty string" do
      it "returns the no-git author" do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_build_author).and_return("")

        subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

        expect(subject.build_author).to eq "no git <no.git@example.com>"
      end
    end
  end

  describe '#commit_authors' do
    it "returns the masked commit authors" do
      allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_commit_authors).and_return([
        "     5\t3v0k4 <riccardo@example.com>\n",
        "    10\tArtur Nowak <artur@example.com>\n",
        "     2\tRiccardo <riccardo@example.com>\n",
        "     3 \tshadre <shadi@example.com>\n",
      ].join(""))

      subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

      expect(subject.commit_authors).to eq([
        { commits: 5, author: "3v0*4 <ri******@ex*****.co*>" },
        { commits: 10, author: "Ar*** No*** <ar***@ex*****.co*>" },
        { commits: 2, author: "Ri****** <ri******@ex*****.co*>" },
        { commits: 3, author: "sh**** <sh***@ex*****.co*>" },
      ])
    end

    context "when the authors command raises an exception" do
      it "returns []" do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_commit_authors).and_raise(Exception)

        subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

        expect(subject.commit_authors).to eq []
      end
    end

    context "when the authors command returns an empty string" do
      it "returns []" do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:git_commit_authors).and_return("")

        subject = KnapsackPro::RepositoryAdapters::GitAdapter.new

        expect(subject.commit_authors).to eq []
      end
    end
  end
end
