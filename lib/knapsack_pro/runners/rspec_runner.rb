module KnapsackPro
  module Runners
    class RSpecRunner < BaseRunner
      def self.run(args)
        runner = new(KnapsackPro::Adapters::RSpecAdapter)

        cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true bundle exec rspec #{args} --default-path #{runner.test_dir} -- #{runner.stringify_test_file_paths}]

        Kernel.system(cmd)
        Kernel.exit($?.exitstatus)
      end
    end
  end
end
