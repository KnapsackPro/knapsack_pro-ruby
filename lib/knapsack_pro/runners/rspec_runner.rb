module KnapsackPro
  module Runners
    class RSpecRunner
      def self.run(args)
        allocator_builder = KnapsackPro::AllocatorBuilder.new(KnapsackPro::Adapters::RspecAdapter)
        allocator = allocator_builder.allocator

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec #{args} --default-path #{allocator_builder.test_dir} -- #{allocator.stringify_node_tests}]

        system(cmd)
        exit($?.exitstatus)
      end
    end
  end
end
