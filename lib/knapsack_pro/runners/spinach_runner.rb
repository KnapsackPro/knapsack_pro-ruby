# frozen_string_literal: true

module KnapsackPro
  module Runners
    class SpinachRunner < BaseRunner
      def self.run(args)
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_spinach

        adapter_class = KnapsackPro::Adapters::SpinachAdapter
        KnapsackPro::Config::Env.set_test_runner_adapter(adapter_class)
        runner = new(adapter_class)

        if runner.test_files_to_execute_exist?
          adapter_class.verify_bind_method_called

          KnapsackPro.tracker.set_prerun_tests(runner.test_file_paths)

          cmd = [
            'bundle',
            'exec',
            'spinach',
            *args.to_s.split(' '),
            '--features_path',
            runner.test_dir,
            '--',
            *runner.test_file_paths
          ]

          Kernel.exec({
            'KNAPSACK_PRO_REGULAR_MODE_ENABLED' => 'true',
            'KNAPSACK_PRO_TEST_SUITE_TOKEN' => ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN']
          }, *cmd)
        end
      end
    end
  end
end
