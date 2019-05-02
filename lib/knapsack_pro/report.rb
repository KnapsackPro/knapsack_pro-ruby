module KnapsackPro
  class Report
    def self.save
      test_files = KnapsackPro.tracker.to_a

      if test_files.empty?
        KnapsackPro.logger.warn("No test files were executed on this CI node.")
        KnapsackPro.logger.debug("When you use knapsack_pro regular mode then probably reason might be very narrowed tests list - you run only tests with specified tag and there are fewer test files with the tag than node total number.")
      end

      create_build_subset(test_files)
    end

    def self.save_subset_queue_to_file
      test_files = KnapsackPro.tracker.to_a

      subset_queue_id = KnapsackPro::Config::Env.subset_queue_id

      FileUtils.mkdir_p(queue_path)

      subset_queue_file_name = "#{subset_queue_id}.json"
      report_path = File.join(queue_path, subset_queue_file_name)
      report_json = JSON.pretty_generate(test_files)

      File.open(report_path, 'w+') do |f|
        f.write(report_json)
      end
    end

    def self.save_node_queue_to_api(executed_test_files_count)
      test_files = []
      Dir.glob("#{queue_path}/*.json").each do |file|
        report = JSON.parse(File.read(file))
        test_files += report
      end

      if test_files.empty?
        if executed_test_files_count == 0
          KnapsackPro.logger.warn("No test files were executed on this CI node.")
          KnapsackPro.logger.debug("When you use knapsack_pro queue mode then probably reason might be that CI node was started after the test files from the queue were already executed by other CI nodes. That is why this CI node has no test files to execute.")
          KnapsackPro.logger.debug("Another reason might be when your CI node failed in a way that prevented knapsack_pro to save time execution data to Knapsack Pro API and you have just tried to retry failed CI node but instead you got no test files to execute. In that case knapsack_pro don't know what testes should be executed here.")
        end

        if executed_test_files_count > 0
          KnapsackPro.logger.error("#{executed_test_files_count} test files were executed on this CI node but the recorded time of it was lost. Probably you have a code (i.e. RSpec hooks) that clears tmp directory in your project. Please ensure you do not remove the content of tmp/knapsack_pro/queue/ directory between tests run. Another reason might be that you forgot to add Knapsack::Adapters::RspecAdapter.bind in your rails_helper.rb or spec_helper.rb. Please follow the installation guide again: https://docs.knapsackpro.com/integration/")
        end
      end

      create_build_subset(test_files)
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
        KnapsackPro.logger.warn('Time execution report was not saved on Knapsack Pro API server due to connection problem.')
      end
    end

    private

    def self.queue_path
      queue_id = KnapsackPro::Config::Env.queue_id
      "tmp/knapsack_pro/queue/#{queue_id}"
    end
  end
end
