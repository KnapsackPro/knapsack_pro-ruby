module KnapsackPro
  class SlowTestFileDeterminer
    TIME_THRESHOLD_PER_CI_NODE = 0.7 # 70%
    REPORT_DIR = "#{KnapsackPro::Config::Env::TMP_DIR}/slow_test_file_determiner"

    # test_files: { 'path' => 'a_spec.rb', 'time_execution' => 0.0 }
    # time_execution: of build distribution (total time of CI build run)
    def self.call(test_files, time_execution)
      time_threshold = (time_execution / KnapsackPro::Config::Env.ci_node_total) * TIME_THRESHOLD_PER_CI_NODE

      test_files.select do |test_file|
        test_file.fetch('time_execution') >= time_threshold
      end
    end

    def self.save_to_json_report(test_files)
      FileUtils.mkdir_p(REPORT_DIR)
      File.write(report_path, test_files.to_json)
    end

    def self.read_from_json_report
      raise 'Report with slow test files was not generated yet. If you have enabled split by test cases https://github.com/KnapsackPro/knapsack_pro-ruby#split-test-files-by-test-cases and you see this error it means that your tests accidentally cleaned up tmp/knapsack_pro directory. Please do not remove this directory during tests runtime!' unless File.exists?(report_path)
      slow_test_files_json_report = File.read(report_path)
      JSON.parse(slow_test_files_json_report)
    end

    private

    def self.report_path
      "#{REPORT_DIR}/slow_test_files_node_#{KnapsackPro::Config::Env.ci_node_index}.json"
    end
  end
end
