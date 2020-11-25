describe KnapsackPro::Client::API::V1::Queues do
  describe '.queue' do
    let(:fixed_queue_split) { double }
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }
    let(:test_files) { double }
    let(:node_build_id) { double }

    subject do
      described_class.queue(
        can_initialize_queue: can_initialize_queue,
        attempt_connect_to_queue: attempt_connect_to_queue,
        commit_hash: commit_hash,
        branch: branch,
        node_total: node_total,
        node_index: node_index,
        test_files: test_files
      )
    end

    before do
      expect(KnapsackPro::Config::Env).to receive(:fixed_queue_split).and_return(fixed_queue_split)
      expect(KnapsackPro::Config::Env).to receive(:ci_node_build_id).and_return(node_build_id)
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=true' do
      let(:can_initialize_queue) { true }
      let(:attempt_connect_to_queue) { true }

      it 'does not send test_files among other params' do
        action = double
        expect(KnapsackPro::Client::API::Action).to receive(:new).with({
          endpoint_path: '/v1/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: can_initialize_queue,
            attempt_connect_to_queue: attempt_connect_to_queue,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            node_build_id: node_build_id,
          }
        }).and_return(action)
        expect(subject).to eq action
      end
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=false' do
      let(:can_initialize_queue) { true }
      let(:attempt_connect_to_queue) { false }

      it 'sends test_files among other params' do
        action = double
        expect(KnapsackPro::Client::API::Action).to receive(:new).with({
          endpoint_path: '/v1/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: can_initialize_queue,
            attempt_connect_to_queue: attempt_connect_to_queue,
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

    context 'when can_initialize_queue=false and attempt_connect_to_queue=false' do
      let(:can_initialize_queue) { false }
      let(:attempt_connect_to_queue) { false }

      it 'does not send test_files among other params' do
        action = double
        expect(KnapsackPro::Client::API::Action).to receive(:new).with({
          endpoint_path: '/v1/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: can_initialize_queue,
            attempt_connect_to_queue: attempt_connect_to_queue,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            node_build_id: node_build_id,
          }
        }).and_return(action)
        expect(subject).to eq action
      end
    end
  end
end
