module KnapsackPro
  class QueueAllocator
    def initialize(args)
      @test_files = args.fetch(:test_files)
      @ci_node_total = args.fetch(:ci_node_total)
      @ci_node_index = args.fetch(:ci_node_index)
      @ci_node_build_id = args.fetch(:ci_node_build_id)
      @repository_adapter = args.fetch(:repository_adapter)
    end

    def test_file_paths(can_initialize_queue, executed_test_files)
      action = build_action(can_initialize_queue)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        prepare_test_files(response)
      else
        KnapsackPro.logger.warn("Fallback mode started. We could not connect with Knapsack Pro API. Your tests will be executed based on directory names. If other CI nodes were able to connect with Knapsack Pro API then you may notice that some of the test files will be executed twice across CI nodes. The most important thing is to guarantee each of test files is run at least once! Read more about fallback mode at https://github.com/KnapsackPro/knapsack_pro-ruby")
        fallback_test_files(executed_test_files)
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

    def fallback_test_files(executed_test_files)
      test_flat_distributor = KnapsackPro::TestFlatDistributor.new(test_files, ci_node_total)
      test_files_for_node_index = test_flat_distributor.test_files_for_node(ci_node_index)
      not_executed_test_files_for_node_index = test_files_for_node_index - executed_test_files
      KnapsackPro::TestFilePresenter.paths(not_executed_test_files_for_node_index)
    end
  end
end
