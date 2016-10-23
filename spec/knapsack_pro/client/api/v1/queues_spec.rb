describe KnapsackPro::Client::API::V1::Queues do
  describe '.queue' do
    let(:can_initialize_queue) { double }
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }
    let(:test_files) { double }

    subject do
      described_class.queue(
        can_initialize_queue: can_initialize_queue,
        commit_hash: commit_hash,
        branch: branch,
        node_total: node_total,
        node_index: node_index,
        test_files: test_files
      )
    end

    it do
      node_build_id = double
      expect(KnapsackPro::Config::Env).to receive(:ci_node_build_id).and_return(node_build_id)

      action = double
      expect(KnapsackPro::Client::API::Action).to receive(:new).with({
        endpoint_path: '/v1/queues/queue',
        http_method: :post,
        request_hash: {
          can_initialize_queue: can_initialize_queue,
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          node_build_id: node_build_id,
          test_files: test_files
        }
      }).and_return(action)
      expect(subject).to eq action
    end
  end
end
