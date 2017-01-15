describe KnapsackPro::Config::CI::SnapCI do
  let(:env) { {} }

  before do
    stub_const('ENV', env)
  end

  it { should be_kind_of KnapsackPro::Config::CI::Base }

  describe '#node_total' do
    subject { described_class.new.node_total }

    context 'when environment exists' do
      let(:env) { { 'SNAP_WORKER_TOTAL' => 4 } }
      it { should eql 4 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_index' do
    subject { described_class.new.node_index }

    context 'when environment exists' do
      let(:env) { { 'SNAP_WORKER_INDEX' => 4 } }
      it { should eql 3 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_build_id' do
    subject { described_class.new.node_build_id }

    context 'when environment exists' do
      let(:env) { { 'SNAP_PIPELINE_COUNTER' => 123 } }
      it { should eql 123 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    context 'when environment exists' do
      let(:env) { { 'SNAP_COMMIT' => '3fa64859337f6e56409d49f865d13fd7' } }
      it { should eql '3fa64859337f6e56409d49f865d13fd7' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#branch' do
    subject { described_class.new.branch }

    context 'when environment exists' do
      context 'when branch present' do
        let(:env) { { 'SNAP_BRANCH' => 'master' } }
        it { should eql 'master' }
      end

      context 'when pull request' do
        let(:env) { { 'SNAP_UPSTREAM_BRANCH' => 'feature-branch' } }
        it { should eql 'feature-branch' }
      end

      context 'branch has higher priority' do
        let(:env) do
          {
            'SNAP_BRANCH' => 'master',
            'SNAP_UPSTREAM_BRANCH' => 'feature-branch'
          }
        end
        it { should eql 'master' }
      end
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#project_dir' do
    subject { described_class.new.project_dir }

    context 'when environment exists' do
      let(:env) { { 'SNAP_WORKING_DIR' => '/var/snap-ci/repo' } }
      it { should eql '/var/snap-ci/repo' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end
end
