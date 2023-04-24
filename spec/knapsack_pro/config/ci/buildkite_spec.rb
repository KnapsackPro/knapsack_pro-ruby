describe KnapsackPro::Config::CI::Buildkite do
  let(:env) { {} }

  before do
    stub_const('ENV', env)
  end

  it { should be_kind_of KnapsackPro::Config::CI::Base }

  describe '#node_total' do
    subject { described_class.new.node_total }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_PARALLEL_JOB_COUNT' => 4 } }
      it { should eql 4 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_index' do
    subject { described_class.new.node_index }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_PARALLEL_JOB' => 3 } }
      it { should eql 3 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_build_id' do
    subject { described_class.new.node_build_id }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_BUILD_NUMBER' => 1514 } }
      it { should eql 1514 }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#node_retry_count' do
    subject { described_class.new.node_retry_count }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_RETRY_COUNT' => '1' } }
      it { should eql '1' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#commit_hash' do
    subject { described_class.new.commit_hash }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_COMMIT' => '3fa64859337f6e56409d49f865d13fd7' } }
      it { should eql '3fa64859337f6e56409d49f865d13fd7' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#branch' do
    subject { described_class.new.branch }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_BRANCH' => 'main' } }
      it { should eql 'main' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#project_dir' do
    subject { described_class.new.project_dir }

    context 'when environment exists' do
      let(:env) { { 'BUILDKITE_BUILD_CHECKOUT_PATH' => '/home/user/knapsack_pro-ruby' } }
      it { should eql '/home/user/knapsack_pro-ruby' }
    end

    context "when environment doesn't exist" do
      it { should be nil }
    end
  end

  describe '#user_seat_string' do
    subject { described_class.new.user_seat_string }

    context 'when the BUILDKITE_BUILD_AUTHOR env var exists' do
      let(:env) do
        { 'BUILDKITE_BUILD_AUTHOR' => 'Jane Doe',
          'BUILDKITE_BUILD_CREATOR' => nil }
      end

      # hashed 'Jane Doe'
      it { should eql '01332c876518a793b7c1b8dfaf6d4b404ff5db09b21c6627ca59710cc24f696a' }
    end

    context 'when the BUILDKITE_BUILD_CREATOR env var exists' do
      let(:env) do
        { 'BUILDKITE_BUILD_AUTHOR' => nil,
          'BUILDKITE_BUILD_CREATOR' => 'John Doe' }
      end

      # hashed 'John Doe'
      it { should eql '6cea57c2fb6cbc2a40411135005760f241fffc3e5e67ab99882726431037f908' }
    end

    context 'when both BUILDKITE_BUILD_AUTHOR and BUILDKITE_BUILD_CREATOR env vars exist' do
      let(:env) do
        { 'BUILDKITE_BUILD_AUTHOR' => 'Jane Doe',
          'BUILDKITE_BUILD_CREATOR' => 'John Doe' }
      end

      # hashed 'Jane Doe'
      it { should eql '01332c876518a793b7c1b8dfaf6d4b404ff5db09b21c6627ca59710cc24f696a' }
    end

    context "when neither env var exists" do
      it { should be nil }
    end
  end
end
