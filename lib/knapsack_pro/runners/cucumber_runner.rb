module KnapsackPro
  module Runners
    class CucumberRunner < BaseRunner
      def self.run(args)
        runner = new(KnapsackPro::Adapters::CucumberAdapter)

        cmd = %Q[bundle exec cucumber #{args} -- #{runner.stringify_test_file_paths}]

        Kernel.system(cmd)
        Kernel.exit($?.exitstatus)
      end
    end
  end
end
