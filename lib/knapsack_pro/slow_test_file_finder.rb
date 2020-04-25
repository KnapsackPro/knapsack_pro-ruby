module KnapsackPro
  class SlowTestFileFinder
    def self.call
      # get list of recorded test files for last CI Build
      test_files_from_api = KnapsackPro::BuildDistributionFetcher.test_files

      # TODO call service to merge a_spec.rb[1:1] taking 1s and a_spec.rb[1:2] taking 2s should be merged into a_spec.rb 3s)
      # pass to it adapter_class

      # TODO KnapsackPro::TestFileFinder.ensure_test_files_exist_on_disk(adapter_class, test_files_from_api)

      # TODO detect slow test files based on get total time of CI build / params[:node_total] * 0.7 and all tests above this threshold should be slow (i.e 20min / 4 nodes * 70% = 3,5min threshold for slow spec)

      # TODO save slow test files on the disk

      # TODO return slow test files
    end
  end
end
