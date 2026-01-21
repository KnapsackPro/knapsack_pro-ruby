describe KnapsackPro::Client::API::V2::Queues do
  describe '.queue' do
    let(:attempt_connect_to_queue) { [false, true].sample }
    let(:batch_uuid) { SecureRandom.uuid }
    let(:branch) { double }
    let(:can_initialize_queue) { [false, true].sample }
    let(:commit_hash) { double }
    let(:fixed_queue_split_?) { [false, true].sample }
    let(:masked_user_seat) { double }
    let(:node_index) { double }
    let(:node_total) { double }
    let(:node_uuid) { SecureRandom.uuid }
    let(:test_queue_id) { "123:abc" }

    before(:each) do
      expect(KnapsackPro::Config::Env).to receive(:fixed_queue_split_?).and_return(fixed_queue_split_?)
      expect(KnapsackPro::Config::Env).to receive(:masked_user_seat).and_return(masked_user_seat)
      expect(KnapsackPro::Config::Env).to receive(:node_uuid).and_return(node_uuid)
      expect(KnapsackPro::Config::Env).to receive(:test_queue_id).and_return(test_queue_id)
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=true' do
      let(:can_initialize_queue) { true }
      let(:attempt_connect_to_queue) { true }

      it do
        actual = described_class.queue(
          attempt_connect_to_queue: attempt_connect_to_queue,
          batch_uuid: batch_uuid,
          branch: branch,
          can_initialize_queue: can_initialize_queue,
          commit_hash: commit_hash,
          node_index: node_index,
          node_total: node_total
        )

        expected_request_hash = {
          attempt_connect_to_queue: attempt_connect_to_queue,
          batch_uuid: batch_uuid,
          branch: branch,
          can_initialize_queue: can_initialize_queue,
          commit_hash: commit_hash,
          fixed_queue_split: fixed_queue_split_?,
          node_index: node_index,
          node_total: node_total,
          node_uuid: node_uuid,
          test_queue_id: test_queue_id,
          user_seat: masked_user_seat
        }
        expect(actual.endpoint_path).to eq("/v2/queues/queue")
        expect(actual.http_method).to eq(:post)
        expect(actual.request_hash).to include(expected_request_hash)
      end
    end

    context 'when can_initialize_queue=true and attempt_connect_to_queue=false' do
      let(:attempt_connect_to_queue) { false }
      let(:build_author) { '3v0*4 <ri******.od***@gm***.co*>' }
      let(:can_initialize_queue) { true }
      let(:commit_authors) { [{ commits: 2, author: build_author }] }
      let(:test_files) { ["spec/a_spec.rb"] }

      before(:each) do
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:build_author).and_return(build_author)
        allow_any_instance_of(KnapsackPro::RepositoryAdapters::GitAdapter).to receive(:commit_authors).and_return(commit_authors)
      end

      it "includes build_authors, commit_authors, test_files" do
        actual = described_class.queue(
          attempt_connect_to_queue: attempt_connect_to_queue,
          batch_uuid: batch_uuid,
          branch: branch,
          can_initialize_queue: can_initialize_queue,
          commit_hash: commit_hash,
          node_index: node_index,
          node_total: node_total,
          test_files: test_files
        )

        expect(actual.request_hash).to include(
          build_author: build_author,
          commit_authors: commit_authors,
          test_files: test_files
        )
      end
    end

    context 'when can_initialize_queue=false and attempt_connect_to_queue=false' do
      let(:attempt_connect_to_queue) { false }
      let(:can_initialize_queue) { false }
      let(:failed_paths) { ['spec/a_spec.rb[1:1]'] }
      let(:test_files) { ["spec/a_spec.rb"] }

      it "includes failed_paths" do
        actual = described_class.queue(
          attempt_connect_to_queue: attempt_connect_to_queue,
          batch_uuid: batch_uuid,
          branch: branch,
          can_initialize_queue: can_initialize_queue,
          commit_hash: commit_hash,
          failed_paths: failed_paths,
          node_index: node_index,
          node_total: node_total,
          test_files: test_files
        )

        expect(actual.request_hash).to include(failed_paths: failed_paths)
      end
    end
  end
end
