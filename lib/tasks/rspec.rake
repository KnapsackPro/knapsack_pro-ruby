require 'knapsack_pro'

namespace :knapsack_pro do
  task :rspec, [:rspec_args] do |_, args|
    KnapsackPro::Runners::RSpecRunner.run(args[:rspec_args])
  end

  desc "Generate the JSON report with for all test suite based on default test pattern or user defined pattern with ENVs"
  task :rspec_test_example_detector do
    detector = KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.new
    detector.generate_json_report
  end
end
