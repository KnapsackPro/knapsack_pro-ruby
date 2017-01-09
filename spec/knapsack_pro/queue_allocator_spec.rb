describe KnapsackPro::QueueAllocator do
  let(:test_files) { double }
  let(:ci_node_total) { double }
  let(:ci_node_index) { double }
  let(:ci_node_build_id) { double }
  let(:repository_adapter) { instance_double(KnapsackPro::RepositoryAdapters::EnvAdapter, commit_hash: double, branch: double) }

  let(:queue_allocator) do
    described_class.new(
      test_files: test_files,
      ci_node_total: ci_node_total,
      ci_node_index: ci_node_index,
      ci_node_build_id: ci_node_build_id,
      repository_adapter: repository_adapter
    )
  end

  describe '#test_file_paths' do
    let(:can_initialize_queue) { double }
    let(:response) { double }

    subject { queue_allocator.test_file_paths(can_initialize_queue) }

    before do
      encrypted_test_files = double
      expect(KnapsackPro::Crypto::Encryptor).to receive(:call).with(test_files).and_return(encrypted_test_files)

      action = double
      expect(KnapsackPro::Client::API::V1::Queues).to receive(:queue).with(
        can_initialize_queue: can_initialize_queue,
        commit_hash: repository_adapter.commit_hash,
        branch: repository_adapter.branch,
        node_total: ci_node_total,
        node_index: ci_node_index,
        node_build_id: ci_node_build_id,
        test_files: encrypted_test_files,
      ).and_return(action)

      connection = instance_double(KnapsackPro::Client::Connection,
                                   call: response,
                                   success?: success?,
                                   errors?: errors?)
      expect(KnapsackPro::Client::Connection).to receive(:new).with(action).and_return(connection)
    end

    context 'when successful request to API' do
      let(:success?) { true }

      context 'when response has errors' do
        let(:errors?) { true }

        it do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when response has no errors' do
        let(:errors?) { false }
        let(:response) do
          {
            'test_files' => [
              { 'path' => 'a_spec.rb' },
              { 'path' => 'b_spec.rb' },
            ]
          }
        end

        before do
          expect(KnapsackPro::Crypto::Decryptor).to receive(:call).with(test_files, response['test_files']).and_call_original
        end

        it { should eq ['a_spec.rb', 'b_spec.rb'] }
      end
    end

    context 'when not successful request to API' do
      let(:success?) { false }
      let(:errors?) { false }

      it do
        expect { subject }.to raise_error("Couldn't connect with Knapsack Pro API. Response: #{response}")
      end
    end
  end
end
