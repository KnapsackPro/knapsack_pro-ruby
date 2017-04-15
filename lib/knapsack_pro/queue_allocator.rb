module KnapsackPro
  class QueueAllocator
    def initialize(args)
      @test_files = args.fetch(:test_files)
      @ci_node_total = args.fetch(:ci_node_total)
      @ci_node_index = args.fetch(:ci_node_index)
      @ci_node_build_id = args.fetch(:ci_node_build_id)
      @repository_adapter = args.fetch(:repository_adapter)
    end

    def test_file_paths(can_initialize_queue)
      action = build_action(can_initialize_queue)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        prepare_test_files(response)
      else
        raise ArgumentError.new("Couldn't connect with Knapsack Pro API. Response: #{response}")
      end
    end

    private

    attr_reader :test_files,
      :ci_node_total,
      :ci_node_index,
      :ci_node_build_id,
      :repository_adapter

    def encrypted_test_files
      KnapsackPro::Crypto::Encryptor.call(test_files)
    end

    def encrypted_branch
      KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch)
    end

    def build_action(can_initialize_queue)
      KnapsackPro::Client::API::V1::Queues.queue(
        can_initialize_queue: can_initialize_queue,
        commit_hash: repository_adapter.commit_hash,
        branch: encrypted_branch,
        node_total: ci_node_total,
        node_index: ci_node_index,
        node_build_id: ci_node_build_id,
        test_files: encrypted_test_files,
      )
    end

    def prepare_test_files(response)
      decrypted_test_files = KnapsackPro::Crypto::Decryptor.call(test_files, response['test_files'])
      KnapsackPro::TestFilePresenter.paths(decrypted_test_files)
    end
  end
end
