module KnapsackPro
  module Runners
    class SpinachRunner < BaseRunner
      def self.run(args)
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_spinach

        adapter_class = KnapsackPro::Adapters::SpinachAdapter
        runner = new(adapter_class)

        if runner.test_files_to_execute_exist?
          adapter_class.verify_bind_method_called

          cmd = %Q[KNAPSACK_PRO_RECORDING_ENABLED=true KNAPSACK_PRO_TEST_SUITE_TOKEN=#{ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN']} bundle exec spinach #{args} --features_path #{runner.test_dir} -- #{runner.stringify_test_file_paths}]

          Kernel.system(cmd)
          Kernel.exit($?.exitstatus) unless $?.exitstatus.zero?
        end
      end
    end
  end
end
