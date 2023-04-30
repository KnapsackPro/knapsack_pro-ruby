describe KnapsackPro::Client::API::V1::BuildDistributions do
  describe '.subset' do
    let(:fixed_test_suite_split) { double }
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }
    let(:ci_build_id) { double }
    let(:user_seat_hash) { double }
    let(:test_files) { double }

    subject do
      described_class.subset(
        cache_read_attempt: cache_read_attempt,
        commit_hash: commit_hash,
        branch: branch,
        node_total: node_total,
        node_index: node_index,
        test_files: test_files
      )
    end

    before do
      expect(KnapsackPro::Config::Env).to receive(:fixed_test_suite_split).and_return(fixed_test_suite_split)
      expect(KnapsackPro::Config::Env).to receive(:ci_node_build_id).and_return(ci_build_id)
      expect(KnapsackPro::Config::Env).to receive(:user_seat_hash).and_return(user_seat_hash)
    end

    context 'when cache_read_attempt=true' do
      let(:cache_read_attempt) { true }

      it 'does not send test_files among other params' do
        action = double
        expect(KnapsackPro::Client::API::Action).to receive(:new).with({
          endpoint_path: '/v1/build_distributions/subset',
          http_method: :post,
          request_hash: {
            fixed_test_suite_split: fixed_test_suite_split,
            cache_read_attempt: cache_read_attempt,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            ci_build_id: ci_build_id,
            user_seat: user_seat_hash,
          }
        }).and_return(action)
        expect(subject).to eq action
      end
    end

    context 'when cache_read_attempt=false' do
      let(:cache_read_attempt) { false }

      it 'sends test_files among other params' do
        action = double
        expect(KnapsackPro::Client::API::Action).to receive(:new).with({
          endpoint_path: '/v1/build_distributions/subset',
          http_method: :post,
          request_hash: {
            fixed_test_suite_split: fixed_test_suite_split,
            cache_read_attempt: cache_read_attempt,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            ci_build_id: ci_build_id,
            user_seat: user_seat_hash,
            test_files: test_files
          }
        }).and_return(action)
        expect(subject).to eq action
      end
    end
  end

  describe '.last' do
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }

    subject do
      described_class.last(
        commit_hash: commit_hash,
        branch: branch,
        node_total: node_total,
        node_index: node_index,
      )
    end

    it do
      action = double
      expect(KnapsackPro::Client::API::Action).to receive(:new).with({
        endpoint_path: '/v1/build_distributions/last',
        http_method: :get,
        request_hash: {
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
        }
      }).and_return(action)
      expect(subject).to eq action
    end
  end
end
