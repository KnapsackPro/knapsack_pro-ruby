module KnapsackPro
  class Allocator
    def initialize(test_files:,
                   ci_node_total:,
                   ci_node_index:,
                   repository_adapter:)
      @test_files = test_files
      @ci_node_total = ci_node_total
      @ci_node_index = ci_node_index
      @repository_adapter = repository_adapter
    end

    def call
      action = KnapsackPro::Client::API::V1::BuildDistributions.subset(
        commit_hash: repository_adapter.commit_hash,
        branch: repository_adapter.branch,
        node_total: ci_node_total,
        node_index: ci_node_index,
        test_files: test_files,
      )
      connection = KnapsackPro::Client::Connection.new(action)
      @response = connection.call
      if connection.success?
        raise response if connection.errors?
        @node_test_files = parse_test_files
      else
        # TODO dumb test suite split when API doesn't respond
      end
    end

    def node_test_files
      @node_test_files
    end

    def stringify_node_test_files
      node_test_files.join(' ')
    end

    private

    attr_reader :test_files,
      :ci_node_total,
      :ci_node_index,
      :repository_adapter,
      :response

    def parse_test_files
      response['test_file'].map { |t| t['path'] }
    end
  end
end
