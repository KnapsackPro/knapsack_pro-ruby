module KnapsackPro
  module Runners
    class CucumberRunner
      def self.run(args)
        adapter_class = KnapsackPro::Adapters::CucumberAdapter
        allocator_builder = KnapsackPro::AllocatorBuilder.new(adapter_class)
        #test_dir = allocator_builder.test_dir

        allocator = allocator_builder.allocator
        test_file_paths = KnapsackPro::TestFilePresenter.stringify_paths(allocator.test_file_paths)

        cmd = %Q[bundle exec cucumber #{args} -- #{test_file_paths}]

        Kernel.system(cmd)
        Kernel.exit($?.exitstatus)
      end
    end
  end
end
