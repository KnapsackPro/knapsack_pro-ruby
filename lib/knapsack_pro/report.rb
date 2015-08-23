module KnapsackPro
  class Report
    def self.save
      repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call
      action = KnapsackPro::Client::API::V1::BuildSubsets.create(
        commit_hash: repository_adapter.commit_hash,
        branch: repository_adapter.branch,
        node_total: KnapsackPro::Config::Env.ci_node_total,
        node_index: KnapsackPro::Config::Env.ci_node_index,
        test_files: KnapsackPro.tracker.to_a,
      )
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        KnapsackPro.logger.info('Saved time execution report on API server.')
      end
    end
  end
end
