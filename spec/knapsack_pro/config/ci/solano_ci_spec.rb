describe KnapsackPro::Config::CI::SolanoCI do
  let(:env) { {} }

  before do
    stub_const('ENV', env)
  end

  it { should be_kind_of KnapsackPro::Config::CI::Base }

  describe '#node_total' do
    subject { described_class.new.node_total }

    it { should be nil }
  end

  describe '#node_index' do
    subject { described_class.new.node_index }

    it { should be nil }
  end

  describe '#node_build_id' do
    subject { described_class.new.node_build_id }

    context 'when environment exists' do
      let(:env) { { 'TDDIUM_SESSION_ID' => 123 } }
      it { should eql 123 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    context 'when environment exists' do
      let(:env) { { 'TDDIUM_CURRENT_COMMIT' => '2e13512fc230d6f9ebf4923352718e4d' } }
      it { should eql '2e13512fc230d6f9ebf4923352718e4d' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#branch' do
    subject { described_class.new.branch }

    context 'when environment exists' do
      let(:env) { { 'TDDIUM_CURRENT_BRANCH' => 'master' } }
      it { should eql 'master' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#project_dir' do
    subject { described_class.new.project_dir }

    context 'when environment exists' do
      let(:env) { { 'TDDIUM_REPO_ROOT' => '/example/repo/root' } }
      it { should eql '/example/repo/root' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end
end
