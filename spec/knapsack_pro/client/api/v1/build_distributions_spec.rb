describe KnapsackPro::Client::API::V1::BuildDistributions do
  describe '.subset' do
    let(:fixed_test_suite_split) { double }
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }
    let(:test_files) { double }

    subject do
      described_class.subset(
        commit_hash: commit_hash,
        branch: branch,
        node_total: node_total,
        node_index: node_index,
        test_files: test_files
      )
    end

    before do
      expect(KnapsackPro::Config::Env).to receive(:fixed_test_suite_split).and_return(fixed_test_suite_split)
    end

    it do
      action = double
      expect(KnapsackPro::Client::API::Action).to receive(:new).with({
        endpoint_path: '/v1/build_distributions/subset',
        http_method: :post,
        request_hash: {
          fixed_test_suite_split: fixed_test_suite_split,
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          test_files: test_files
        }
      }).and_return(action)
      expect(subject).to eq action
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
