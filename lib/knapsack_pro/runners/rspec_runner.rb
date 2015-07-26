module KnapsackPro
  module Runners
    class RSpecRunner
      def self.run(args)
        adapter_class = KnapsackPro::Adapters::RSpecAdapter
        allocator_builder = KnapsackPro::AllocatorBuilder.new(adapter_class)
        test_dir = allocator_builder.test_dir

        allocator = allocator_builder.allocator
        allocator.call
        stringify_node_test_files = allocator.stringify_node_test_files

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec #{args} --default-path #{test_dir} -- #{stringify_node_test_files}]

        system(cmd)
        exit($?.exitstatus)
      end
    end
  end
end
