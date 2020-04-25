module KnapsackPro
  class SlowTestFileFinder
    def self.call(adapter_class)
      if KnapsackPro::Config::Env.test_files_encrypted?
        raise 'Split by test cases is not possible when you have enabled test file names encryption ( https://github.com/KnapsackPro/knapsack_pro-ruby#test-file-names-encryption ). You need to disable encryption with KNAPSACK_PRO_TEST_FILES_ENCRYPTED=false in order to use split by test cases https://github.com/KnapsackPro/knapsack_pro-ruby#split-test-files-by-test-cases'
      end

      # get list of recorded test files for last CI Build
      build_distribution_entity = KnapsackPro::BuildDistributionFetcher.call
      test_files_from_api = build_distribution_entity.test_files

      merged_test_files_from_api = KnapsackPro::TestCaseMergers::BaseMerger.call(adapter_class, test_files_from_api)

      # TODO KnapsackPro::TestFileFinder.select_test_files_that_can_be_run(adapter_class, merged_test_files_from_api)

      # TODO detect slow test files based on get total time of CI build / params[:node_total] * 0.7 and all tests above this threshold should be slow (i.e 20min / 4 nodes * 70% = 3,5min threshold for slow spec)

      # TODO save slow test files on the disk

      # TODO return slow test files
    end
  end
end
