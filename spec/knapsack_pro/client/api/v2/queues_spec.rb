describe KnapsackPro::Client::API::V2::Queues do
  describe '.queue' do
    let(:fixed_queue_split) { double }
    let(:commit_hash) { double }
    let(:branch) { double }
    let(:node_total) { double }
    let(:node_index) { double }
    let(:test_files) { double }
    let(:node_build_id) { double }
    let(:masked_user_seat) { double }
    let(:can_initialize_queue) { [false, true].sample }
    let(:attempt_connect_to_queue) { [false, true].sample }
    let(:node_uuid) { SecureRandom.uuid }

    before(:each) do
      expect(KnapsackPro::Config::Env).to receive(:fixed_queue_split).and_return(fixed_queue_split)
      expect(KnapsackPro::Config::Env).to receive(:ci_node_build_id).and_return(node_build_id)
      expect(KnapsackPro::Config::Env).to receive(:masked_user_seat).and_return(masked_user_seat)
      expect(KnapsackPro::Config::Env).to receive(:node_uuid).and_return(node_uuid)
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=true' do
      let(:can_initialize_queue) { true }
      let(:attempt_connect_to_queue) { true }

      it 'does not send test_files nor authors' do
        expected = KnapsackPro::Client::API::Action.new(
          endpoint_path: '/v2/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: true,
            attempt_connect_to_queue: true,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            node_build_id: node_build_id,
            user_seat: masked_user_seat,
            node_uuid: node_uuid
          }
        )

        actual = described_class.queue(
          can_initialize_queue: can_initialize_queue,
          attempt_connect_to_queue: attempt_connect_to_queue,
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          test_files: test_files
        )

        expect(actual).to eq(expected)
      end
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=false' do
      let(:can_initialize_queue) { true }
      let(:attempt_connect_to_queue) { false }
      let(:build_author) { '3v0*4 <ri******.od***@gm***.co*>' }
      let(:commit_authors) { [{ commits: 2, author: build_author }] }

      before(:each) do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:build_author).and_return(build_author)
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:commit_authors).and_return(commit_authors)
      end

      it 'sends test_files and authors' do
        expected = KnapsackPro::Client::API::Action.new(
          endpoint_path: '/v2/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: true,
            attempt_connect_to_queue: false,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            node_build_id: node_build_id,
            user_seat: masked_user_seat,
            test_files: test_files,
            build_author: build_author,
            commit_authors: commit_authors,
            node_uuid: node_uuid
          }
        )

        actual = described_class.queue(
          can_initialize_queue: can_initialize_queue,
          attempt_connect_to_queue: attempt_connect_to_queue,
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          test_files: test_files
        )

        expect(actual).to eq(expected)
      end
    end

    context 'when can_initialize_queue=false and attempt_connect_to_queue=false' do
      let(:can_initialize_queue) { false }
      let(:attempt_connect_to_queue) { false }
      let(:test_paths) { ['spec/a_spec.rb'] }
      let(:failed_test_id_paths) { ['spec/a_spec.rb[1:1]'] }

      it 'does not send test_files nor authors' do
        expected = KnapsackPro::Client::API::Action.new(
          endpoint_path: '/v2/queues/queue',
          http_method: :post,
          request_hash: {
            fixed_queue_split: fixed_queue_split,
            can_initialize_queue: false,
            attempt_connect_to_queue: false,
            commit_hash: commit_hash,
            branch: branch,
            node_total: node_total,
            node_index: node_index,
            node_build_id: node_build_id,
            user_seat: masked_user_seat,
            node_uuid: node_uuid,
            test_paths: test_paths,
            failed_test_id_paths: failed_test_id_paths
          }
        )

        actual = described_class.queue(
          can_initialize_queue: can_initialize_queue,
          attempt_connect_to_queue: attempt_connect_to_queue,
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          test_files: test_files,
          test_paths: test_paths,
          failed_test_id_paths: failed_test_id_paths
        )

        expect(actual).to eq(expected)
      end
    end
  end
end
