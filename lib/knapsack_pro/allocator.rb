# frozen_string_literal: true

module KnapsackPro
  class Allocator
    class Split
      def initialize(connection, response)
        @connection = connection
        @response = response

        raise ArgumentError.new(connection.response) if connection.errors?
      end

      def exists?
        raise "Connection failed. Please report this as a bug: #{KnapsackPro::Urls::SUPPORT}" if connection_failed?
        return false if connection.api_code == KnapsackPro::Client::API::V1::BuildDistributions::TEST_SUITE_SPLIT_CACHE_MISS_CODE

        true
      end

      def connection_failed?
        !connection.success?
      end

      def test_files
        response.fetch('test_files')
      end

      private

      attr_reader :connection, :response
    end

    def initialize(args)
      @test_suite = args.fetch(:test_suite)
      @ci_node_total = args.fetch(:ci_node_total)
      @ci_node_index = args.fetch(:ci_node_index)
      @repository_adapter = args.fetch(:repository_adapter)
    end

    def test_file_paths
      split = pull_tests

      return switch_to_fallback_mode if split.connection_failed?
      return normalize_test_files(split.test_files) if split.exists?

      test_files_result = test_suite.test_files

      return try_initializing_test_suite_split(test_files_result.tests) if test_files_result.tests_found_quickly?

      # The tests to run were found slowly. By that time, the test suite split could have already been initialized by another CI node.
      # Attempt to pull tests to avoid the attempt to initialize the test suite split unnecessarily (test suite split initialization is an expensive request with a big test files payload).
      split = pull_tests

      return switch_to_fallback_mode if split.connection_failed?
      return normalize_test_files(split.test_files) if split.exists?

      try_initializing_test_suite_split(test_files_result.tests)
    end

    private

    attr_reader :test_suite,
      :ci_node_total,
      :ci_node_index,
      :repository_adapter

    def encrypted_branch
      KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch)
    end

    def normalize_test_files(test_files)
      decrypted_test_files = KnapsackPro::Crypto::Decryptor.call(test_suite, test_files)
      KnapsackPro::TestFilePresenter.paths(decrypted_test_files)
    end

    def build_action(cache_read_attempt:, test_files: nil)
      unless cache_read_attempt
        raise 'Test files are required when initializing a new test suite split.' if test_files.nil?
        test_files = KnapsackPro::Crypto::Encryptor.call(test_files)
      end

      KnapsackPro::Client::API::V1::BuildDistributions.subset(
        cache_read_attempt: cache_read_attempt,
        commit_hash: repository_adapter.commit_hash,
        branch: encrypted_branch,
        node_total: ci_node_total,
        node_index: ci_node_index,
        test_files: test_files,
      )
    end

    def pull_tests
      action = build_action(cache_read_attempt: true)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      Split.new(connection, response)
    end

    def initialize_test_suite_split(tests_to_run)
      action = build_action(cache_read_attempt: false, test_files: tests_to_run)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      Split.new(connection, response)
    end

    def try_initializing_test_suite_split(tests)
      split = initialize_test_suite_split(tests)

      return switch_to_fallback_mode if split.connection_failed?

      normalize_test_files(split.test_files)
    end

    def switch_to_fallback_mode
      if !KnapsackPro::Config::Env.fallback_mode_enabled?
        message = "Fallback Mode was disabled with KNAPSACK_PRO_FALLBACK_MODE_ENABLED=false. Please restart this CI node to retry tests. Most likely Fallback Mode was disabled due to #{KnapsackPro::Urls::REGULAR_MODE__CONNECTION_ERROR_WITH_FALLBACK_ENABLED_FALSE}"
        KnapsackPro.logger.error(message)
        exit_code = KnapsackPro::Config::Env.fallback_mode_error_exit_code
        Kernel.exit(exit_code)
      elsif KnapsackPro::Config::Env.ci_node_retry_count > 0
        message = "knapsack_pro gem could not connect to Knapsack Pro API and the Fallback Mode cannot be used this time. Running tests in Fallback Mode are not allowed for retried parallel CI node to avoid running the wrong set of tests. Please manually retry this parallel job on your CI server then knapsack_pro gem will try to connect to Knapsack Pro API again and will run a correct set of tests for this CI node. Learn more #{KnapsackPro::Urls::REGULAR_MODE__CONNECTION_ERROR_WITH_FALLBACK_ENABLED_TRUE_AND_POSITIVE_RETRY_COUNT}"
        unless KnapsackPro::Config::Env.fixed_test_suite_split?
          message += " Please ensure you have set KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true to allow Knapsack Pro API remember the recorded CI node tests so when you retry failed tests on the CI node then the same set of tests will be executed. See more #{KnapsackPro::Urls::FIXED_TEST_SUITE_SPLIT}"
        end
        KnapsackPro.logger.error(message)
        exit_code = KnapsackPro::Config::Env.fallback_mode_error_exit_code
        Kernel.exit(exit_code)
      else
        KnapsackPro.logger.warn("Fallback mode started. We could not connect with Knapsack Pro API. Your tests will be executed based on directory names. Read more about fallback mode at #{KnapsackPro::Urls::FALLBACK_MODE}")
        fallback_test_files
      end
    end

    def fallback_test_files
      test_flat_distributor = KnapsackPro::TestFlatDistributor.new(test_suite.fallback_test_files, ci_node_total)
      test_files_for_node_index = test_flat_distributor.test_files_for_node(ci_node_index)
      KnapsackPro::TestFilePresenter.paths(test_files_for_node_index)
    end
  end
end
