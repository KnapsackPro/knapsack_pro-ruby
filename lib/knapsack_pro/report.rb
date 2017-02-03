module KnapsackPro
  class Report
    def self.save
      test_files = KnapsackPro.tracker.to_a
      create_build_subset(test_files)
    end

    def self.save_subset_queue_to_file
      test_files = KnapsackPro.tracker.to_a
      KnapsackPro.tracker.reset!

      subset_queue_id = KnapsackPro::Config::Env.subset_queue_id

      FileUtils.mkdir_p(queue_path)

      subset_queue_file_name = "#{subset_queue_id}.json"
      report_path = File.join(queue_path, subset_queue_file_name)
      report_json = JSON.pretty_generate(test_files)

      File.open(report_path, 'w+') do |f|
        f.write(report_json)
      end
    end

    def self.save_node_queue_to_api
      test_files = []
      Dir.glob("#{queue_path}/*.json").each do |file|
        report = JSON.parse(File.read(file))
        test_files += report
      end

      create_build_subset(test_files)
    end

    def self.create_build_subset(test_files)
      if test_files.empty?
        KnapsackPro.logger.info("Didn't save time execution report on API server because there are no test files matching criteria on this node. Probably reason might be very narrowed tests list - you run only tests with specified tag and there are fewer test files with the tag than node total number.")
        return
      end

      repository_adapter = KnapsackPro::RepositoryAdapterInitiator.call
      test_files = KnapsackPro::Utils.unsymbolize(test_files)
      encrypted_test_files = KnapsackPro::Crypto::Encryptor.call(test_files)
      action = KnapsackPro::Client::API::V1::BuildSubsets.create(
        commit_hash: repository_adapter.commit_hash,
        branch: repository_adapter.branch,
        node_total: KnapsackPro::Config::Env.ci_node_total,
        node_index: KnapsackPro::Config::Env.ci_node_index,
        test_files: encrypted_test_files,
      )
      connection = KnapsackPro::Client::Connection.new(action)
      response = connection.call
      if connection.success?
        raise ArgumentError.new(response) if connection.errors?
        KnapsackPro.logger.info('Saved time execution report on API server.')
      end
    end

    private

    def self.queue_path
      queue_id = KnapsackPro::Config::Env.queue_id
      "tmp/knapsack_pro/queue/#{queue_id}"
    end
  end
end
