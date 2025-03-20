describe KnapsackPro::Config::CI::Mint do
  let(:env) { {} }

  before do
    stub_const('ENV', env)
  end

  it { should be_kind_of KnapsackPro::Config::CI::Base }

  describe '#node_total' do
    subject { described_class.new.node_total }

    context 'when the environment exists' do
      let(:env) { { 'MINT_PARALLEL_TOTAL' => 4 } }
      it { should eql 4 }
    end

    context "when the environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_index' do
    subject { described_class.new.node_index }

    context 'when the environment exists' do
      let(:env) { { 'MINT_PARALLEL_INDEX' => 3 } }
      it { should eql 3 }
    end

    context "when the environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_build_id' do
    subject { described_class.new.node_build_id }

    context 'when the environment exists' do
      let(:env) { { 'MINT_RUN_ID' => 123 } }
      it { should eql 123 }
    end

    context "when the environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    context 'when the environment exists' do
      let(:env) { { 'MINT_GIT_COMMIT_SHA' => '3fa64859337f6e56409d49f865d13fd7' } }
      it { should eql '3fa64859337f6e56409d49f865d13fd7' }
    end

    context "when the environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#branch' do
    subject { described_class.new.branch }

    context 'when the environment exists' do
      let(:env) { { 'MINT_GIT_REF_NAME' => 'main' } }
      it { should eql 'main' }
    end

    context "when the environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#project_dir' do
    subject { described_class.new.project_dir }

    it { should be nil }
  end

  describe '#user_seat' do
    subject { described_class.new.user_seat }

    context 'when the MINT_ACTOR_ID env var exists' do
      let(:env) do
        { 'MINT_ACTOR_ID' => '123',
          'MINT_GIT_COMMITTER_EMAIL' => nil }
      end

      it { should eql '123' }
    end

    context 'when the MINT_GIT_COMMITTER_EMAIL env var exists' do
      let(:env) do
        { 'MINT_ACTOR_ID' => nil,
          'MINT_GIT_COMMITTER_EMAIL' => 'john@doe.com' }
      end

      it { should eql 'john@doe.com' }
    end

    context 'when both MINT_ACTOR_ID and MINT_GIT_COMMITTER_EMAIL env vars exist' do
      let(:env) do
        { 'MINT_ACTOR_ID' => '123',
          'MINT_GIT_COMMITTER_EMAIL' => 'john@doe.com' }
      end

      it { should eql '123' }
    end

    context "when neither env var exists" do
      it { should be nil }
    end
  end
end
