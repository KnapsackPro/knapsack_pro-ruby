# frozen_string_literal: true

module KnapsackPro
  class RSpecSlowTestFileFinder
    def initialize(build_distribution_fetcher)
      @build_distribution_fetcher = build_distribution_fetcher
    end

    def call
      if KnapsackPro::Config::Env.test_files_encrypted?
        raise "Split by test cases is not possible when you have enabled test file names encryption ( #{KnapsackPro::Urls::ENCRYPTION} ). You need to disable encryption with KNAPSACK_PRO_TEST_FILES_ENCRYPTED=false in order to use split by test cases #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES}"
      end

      test_files_from_api = @build_distribution_fetcher.call.test_files
      merged_test_files_from_api = KnapsackPro::TestCaseMergers::RSpecMerger.new(test_files_from_api).call
      test_files_existing_on_disk = KnapsackPro::TestFileFinder.select_test_files_that_can_be_run(KnapsackPro::Adapters::RSpecAdapter, merged_test_files_from_api)
      KnapsackPro::SlowTestFileDeterminer.call(test_files_existing_on_disk)
    end
  end
end
