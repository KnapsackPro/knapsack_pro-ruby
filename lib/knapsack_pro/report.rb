# frozen_string_literal: true

module KnapsackPro
  class Report
    def self.save(test_files = nil)
      if test_files.nil?
        test_files = KnapsackPro.tracker.to_a
      end

      if test_files.empty?
        KnapsackPro.logger.info("No tests were executed because the test queue is empty.")
      end

      acknowledge_single_batch(test_files)
      create_build_subset(test_files)
    end

    def self.save_subset_queue_to_file
      test_files = KnapsackPro.tracker.to_a

      subset_queue_id = KnapsackPro::Config::Env.subset_queue_id

      KnapsackPro::Config::TempFiles.ensure_temp_directory_exists!
      FileUtils.mkdir_p(queue_path)

      subset_queue_file_name = "#{subset_queue_id}.json"
      report_path = File.join(queue_path, subset_queue_file_name)
      report_json = JSON.pretty_generate(test_files)

      File.open(report_path, 'w+') do |f|
        f.write(report_json)
      end
    end

    def self.save_node_queue_to_api(test_files = nil)
      if test_files.nil?
        test_files = []
        Dir.glob("#{queue_path}/*.json").each do |file|
          report = JSON.parse(File.read(file))
          test_files += report
        end
      end

      if test_files.empty?
        KnapsackPro.logger.info("No tests were executed because the test queue is empty.")
      end

      measured_test_files = test_files
        .map { |t| t['time_execution'] }
        .select { |time_execution| time_execution != KnapsackPro::Tracker::DEFAULT_TEST_FILE_TIME }

      if test_files.size > 0 && measured_test_files.size == 0
        KnapsackPro.logger.warn("#{test_files.size} test files were executed, but their execution time could not be recorded. This usually happens when one of the following is true:")
        KnapsackPro.logger.warn('- The `.knapsack_pro` directory (or its contents) were removed during the run.')
        KnapsackPro.logger.warn("- The `bind` method was not called in the test runner configuration. See: #{KnapsackPro::Urls::INSTALLATION_GUIDE}")
        KnapsackPro.logger.warn('- The test files did not run any tests because they are empty, contain only pending tests, or have syntax errors.')
      end

      create_build_subset(test_files)
    end

    # TODO: Add support for Retry-only-Failures
    def self.acknowledge_single_batch(test_files)
      repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call
      paths = KnapsackPro::Utils.unsymbolize(test_files).map { |test_file| test_file.fetch('path') }
      failed_paths = KnapsackPro::Crypto::Encryptor.paths(paths)
      action = KnapsackPro::Client::API::V2::Queues.queue(
        attempt_connect_to_queue: false,
        batch_id: ENV['KNAPSACK_PRO_BATCH_ID'], # nil in Fallback Mode
        batch_index: 1,
        branch: KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch),
        can_initialize_queue: false,
        commit_hash: repository_adapter.commit_hash,
        failed_paths: failed_paths,
        node_total: KnapsackPro::Config::Env.ci_node_total,
        node_index: KnapsackPro::Config::Env.ci_node_index,
        node_uuid: ENV.fetch('KNAPSACK_PRO_NODE_UUID'),
        single_batch: true
      )

      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        KnapsackPro.logger.debug('Acknowledged single batch.')
      else
        KnapsackPro.logger.warn('Single batch was not acknowledged due to connection problems.')
      end
    end

    def self.create_build_subset(test_files)
      repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call
      test_files = KnapsackPro::Utils.unsymbolize(test_files)
      encrypted_test_files = KnapsackPro::Crypto::Encryptor.call(test_files)
      encrypted_branch = KnapsackPro::Crypto::BranchEncryptor.call(repository_adapter.branch)
      action = KnapsackPro::Client::API::V1::BuildSubsets.create(
        commit_hash: repository_adapter.commit_hash,
        branch: encrypted_branch,
        node_total: KnapsackPro::Config::Env.ci_node_total,
        node_index: KnapsackPro::Config::Env.ci_node_index,
        test_files: encrypted_test_files,
      )
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        KnapsackPro.logger.debug('Saved time execution report on Knapsack Pro API server.')
      else
        KnapsackPro.logger.warn('Time execution report was not saved on Knapsack Pro API server due to connection problems.')
      end
    end

    private

    def self.queue_path
      "#{KnapsackPro::Config::TempFiles::TEMP_DIRECTORY_PATH}/queue/#{KnapsackPro::Config::Env.queue_id}"
    end
  end
end
