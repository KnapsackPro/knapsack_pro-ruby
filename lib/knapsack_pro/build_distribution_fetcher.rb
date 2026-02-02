# frozen_string_literal: true

module KnapsackPro
  class BuildDistributionFetcher
    class BuildDistributionEntity
      def initialize(response)
        @response = response
      end

      def test_files
        response.fetch('test_files')
      end

      def queue_url # Can be present only when using the initialize command
        response.fetch('queue_url', nil)
      end

      private

      attr_reader :response
    end

    def call
      connection = KnapsackPro::Client::Connection.new(build_action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        BuildDistributionEntity.new(response)
      else
        KnapsackPro.logger.warn("Failed to fetch slow test files. Split by Test Examples disabled. See: #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}")
        BuildDistributionEntity.new({ 'time_execution' => 0.0, 'test_files' => [] })
      end
    end

    private

    def repository_adapter
      @repository_adapter ||= KnapsackPro::RepositoryAdapterInitiator.call
    end

    def build_action
      request_hash = {
        commit_hash: repository_adapter.commit_hash,
        branch: repository_adapter.branch,
        node_total: KnapsackPro::Config::Env.ci_node_total,
        node_index: KnapsackPro::Config::Env.ci_node_index
      }.merge(additional_params)

      KnapsackPro::Client::API::V1::BuildDistributions.last(request_hash)
    end

    def additional_params
      {}
    end
  end

  class OptimizedBuildDistributionFetcher < BuildDistributionFetcher
    private

    def additional_params
      {
        node_build_id: KnapsackPro::Config::Env.ci_node_build_id,
        none_if_queue_initialized: true
      }
    end
  end
end
