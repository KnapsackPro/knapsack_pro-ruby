# frozen_string_literal: true

module KnapsackPro
  class QueueAllocator
    FallbackModeError = Class.new(StandardError)

    class Batch
      def initialize(connection, response)
        @connection = connection
        @response = response

        raise ArgumentError.new(connection.response) if connection.errors?
      end

      def queue_exists?
        raise "Connection failed. Please report this as a bug: #{KnapsackPro::Urls::SUPPORT}" if connection_failed?
        return false if connection.api_code == KnapsackPro::Client::API::V2::Queues::CODE_ATTEMPT_CONNECT_TO_QUEUE_FAILED

        true
      end

      def connection_failed?
        !connection.success?
      end

      def test_files
        paths.map { |path| { "path" => path, "time_execution" => nil } }
      end

      def paths
        response.fetch('paths')
      end

      def id
        response.fetch('batch_id', nil)
      end

      private

      attr_reader :connection, :response
    end

    def initialize(args)
      @test_suite = args.fetch(:test_suite)
      @ci_node_total = args.fetch(:ci_node_total)
      @ci_node_index = args.fetch(:ci_node_index)
      @repository_adapter = args.fetch(:repository_adapter)
      @fallback_mode = false
      @batch_index = -1
      @node_uuid = SecureRandom.uuid
      @current_batch = nil
    end

    def test_file_paths(can_initialize_queue, executed_test_files, time_tracker: nil)
      @batch_index += 1
      return [] if @fallback_mode

      batch = pull_tests_from_queue(can_initialize_queue, time_tracker: time_tracker)

      return switch_to_fallback_mode(executed_test_files: executed_test_files) if batch.connection_failed?
      return normalize_test_files(batch.test_files) if batch.queue_exists?

      test_files_result = test_suite.calculate_test_files

      return try_initializing_queue(test_files_result.test_files.map { |test| test.fetch("path") }, time_tracker: time_tracker) if test_files_result.quick?

      # The tests to run were found slowly. By that time, the queue could have already been initialized by another CI node.
      # Attempt to pull tests from the queue to avoid the attempt to initialize the queue unnecessarily (queue initialization is an expensive request with a big test files payload).
      batch = pull_tests_from_queue(can_initialize_queue, time_tracker: time_tracker)

      return switch_to_fallback_mode(executed_test_files: executed_test_files) if batch.connection_failed?
      return normalize_test_files(batch.test_files) if batch.queue_exists?

      try_initializing_queue(test_files_result.test_files.map { |test| test.fetch("path") }, time_tracker: time_tracker)
    end

    private

    attr_reader :test_suite, :ci_node_total, :ci_node_index, :repository_adapter

    def encrypted_branch
      KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch)
    end

    def normalize_test_files(test_files)
      decrypted_test_files = KnapsackPro::Crypto::Decryptor.call(test_suite, test_files)
      KnapsackPro::TestFilePresenter.paths(decrypted_test_files)
    end

    # time_tracker is nil for non-RSpec queue runners
    def build_action(can_initialize_queue:, attempt_connect_to_queue:, time_tracker:, paths: nil)
      if can_initialize_queue && !attempt_connect_to_queue
        raise 'Test files are required when initializing a new queue.' if paths.nil?
        paths = KnapsackPro::Crypto::Encryptor.paths(paths)
      end

      failed_paths =
        if time_tracker
          KnapsackPro::Crypto::Encryptor.paths(time_tracker.current_batch_failed_paths)
        elsif @batch_index.positive?
          KnapsackPro::Crypto::Encryptor.paths(@current_batch.paths)
        end

      KnapsackPro::Client::API::V2::Queues.queue(
        attempt_connect_to_queue: attempt_connect_to_queue,
        batch_id: @current_batch&.id,
        batch_index: @batch_index,
        branch: encrypted_branch,
        can_initialize_queue: can_initialize_queue,
        commit_hash: repository_adapter.commit_hash,
        failed_paths: failed_paths,
        node_index: ci_node_index,
        node_total: ci_node_total,
        node_uuid: @node_uuid,
        paths: paths
      )
    end

    def pull_tests_from_queue(can_initialize_queue, time_tracker: nil)
      action = build_action(can_initialize_queue: can_initialize_queue, attempt_connect_to_queue: can_initialize_queue, time_tracker: time_tracker)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      @current_batch = Batch.new(connection, response)
    end

    def initialize_queue(paths, time_tracker: nil)
      action = build_action(can_initialize_queue: true, attempt_connect_to_queue: false, paths: paths, time_tracker: time_tracker)
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      @current_batch = Batch.new(connection, response)
    end

    def try_initializing_queue(paths, time_tracker: nil)
      result = initialize_queue(paths, time_tracker: time_tracker)
      return switch_to_fallback_mode(executed_test_files: []) if result.connection_failed?

      normalize_test_files(result.test_files)
    end

    def switch_to_fallback_mode(executed_test_files:)
      @fallback_mode = true

      if !KnapsackPro::Config::Env.fallback_mode_enabled?
        message = "Fallback Mode was disabled with KNAPSACK_PRO_FALLBACK_MODE_ENABLED=false. Please restart this CI node to retry tests. Most likely Fallback Mode was disabled due to #{KnapsackPro::Urls::NORMAL_MODE__CONNECTION_ERROR_WITH_FALLBACK_ENABLED_FALSE}"
        KnapsackPro.logger.error(message)
        raise FallbackModeError.new(message)
      elsif KnapsackPro::Config::Env.ci_node_retry_count > 0
        message = "knapsack_pro gem could not connect to Knapsack Pro API and the Fallback Mode cannot be used this time. Running tests in Fallback Mode are not allowed for retried parallel CI node to avoid running the wrong set of tests. Please manually retry this parallel job on your CI server then knapsack_pro gem will try to connect to Knapsack Pro API again and will run a correct set of tests for this CI node. Learn more #{KnapsackPro::Urls::NORMAL_MODE__CONNECTION_ERROR_WITH_FALLBACK_ENABLED_TRUE_AND_POSITIVE_RETRY_COUNT}"
        KnapsackPro.logger.error(message)
        raise FallbackModeError.new(message)
      else
        KnapsackPro.logger.warn("Fallback mode started. We could not connect with Knapsack Pro API. Your tests will be executed based on directory names. If other CI nodes were able to connect with Knapsack Pro API then you may notice that some of the test files will be executed twice across CI nodes. The most important thing is to guarantee each of test files is run at least once! Read more about fallback mode at #{KnapsackPro::Urls::FALLBACK_MODE}")
        fallback_test_files(executed_test_files)
      end
    end

    # Run file paths to guarantee at-least-once execution across CI nodes.
    def fallback_test_files(executed_test_files)
      test_flat_distributor = KnapsackPro::TestFlatDistributor.new(test_suite.all_test_files_to_run, ci_node_total)
      test_files_for_node_index = test_flat_distributor.test_files_for_node(ci_node_index)
      KnapsackPro::TestFilePresenter.paths(test_files_for_node_index) - executed_test_files
    end
  end
end
