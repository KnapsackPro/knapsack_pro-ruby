module KnapsackPro
  module Runners
    class RSpecRunner
      def self.run(args)
        allocator = KnapsackPro::AllocatorBuilder.call(KnapsackPro::Adapters::RspecAdapter)

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec #{args} --default-path #{allocator.test_dir} -- #{allocator.stringify_node_tests}]

        system(cmd)
        exit($?.exitstatus)
      end
    end
  end
end
