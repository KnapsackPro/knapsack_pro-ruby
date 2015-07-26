module KnapsackPro
  module Runners
    class RSpecRunner
      def self.run(args)
        adapter_class = KnapsackPro::Adapters::RSpecAdapter
        allocator_builder = KnapsackPro::AllocatorBuilder.new(adapter_class)
        test_dir = allocator_builder.test_dir

        allocator = allocator_builder.allocator
        test_file_paths = KnapsackPro::TestFilePresenter.stringify_paths(allocator.test_file_paths)

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec #{args} --default-path #{test_dir} -- #{test_file_paths}]

        Kernel.system(cmd)
        Kernel.exit($?.exitstatus)
      end
    end
  end
end
