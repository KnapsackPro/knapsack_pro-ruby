module KnapsackPro
  class SlowTestFileDeterminer
    TIME_THRESHOLD_PER_CI_NODE = 0.7 # 70%

    # test_files: { 'path' => 'a_spec.rb', 'time_execution' => 0.0 }
    # time_execution: of build distribution (total time of CI build run)
    def self.call(test_files, time_execution)
      time_threshold = (time_execution / KnapsackPro::Config::Env.ci_node_total) * TIME_THRESHOLD_PER_CI_NODE

      test_files.select do |test_file|
        test_file.fetch('time_execution') >= time_threshold
      end
    end
  end
end
