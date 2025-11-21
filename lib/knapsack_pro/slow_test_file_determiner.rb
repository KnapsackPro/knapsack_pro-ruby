# frozen_string_literal: true

module KnapsackPro
  class SlowTestFileDeterminer
    TIME_THRESHOLD_PER_CI_NODE = 0.7 # 70%

    # test_files: { 'path' => 'a_spec.rb', 'time_execution' => 0.0 }
    def self.call(test_files)
      total_execution_time = test_files.sum { |test_file| test_file.fetch('time_execution') }
      time_threshold = (total_execution_time / KnapsackPro::Config::Env.ci_node_total) * TIME_THRESHOLD_PER_CI_NODE

      test_files.select do |test_file|
        execution_time = test_file.fetch('time_execution')
        next false if execution_time.zero?
        next true if execution_time >= time_threshold
        next false unless KnapsackPro::Config::Env.slow_test_file_threshold?

        execution_time >= KnapsackPro::Config::Env.slow_test_file_threshold
      end
    end
  end
end
