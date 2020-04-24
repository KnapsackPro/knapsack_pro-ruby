module KnapsackPro
  class BuildDistributionFetcher
    def test_files
      connection = KnapsackPro::Client::Connection.new(build_action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        prepare_test_files(response)
      else
        KnapsackPro.logger.warn("Fallback behaviour started. We could not connect with Knapsack Pro API to fetch last CI build test files that are needed to determine slow test files. No test files will be split by test cases. It means all test files will be split by the whole test files as if split by test cases would be disabled https://github.com/KnapsackPro/knapsack_pro-ruby/tree/rspec-split-by-examples-selected-test-files#split-test-files-by-test-cases")
        []
      end
    end

    private

    def repository_adapter
      @repository_adapter ||= KnapsackPro::RepositoryAdapterInitiator.call
    end

    def encrypted_branch
      KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch)
    end

    def build_action
      KnapsackPro::Client::API::V1::BuildDistributions.last(
        commit_hash: repository_adapter.commit_hash,
        branch: encrypted_branch,
        node_total: ci_node_total,
        node_index: ci_node_index,
      )
    end

    def all_test_files
      # TODO
    end

    def prepare_test_files(response)
      decrypted_test_files = KnapsackPro::Crypto::Decryptor.call(all_test_files, response['test_files'])
      KnapsackPro::TestFilePresenter.paths(decrypted_test_files)
    end
  end
end
