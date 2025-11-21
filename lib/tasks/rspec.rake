# frozen_string_literal: true

require 'knapsack_pro'

namespace :knapsack_pro do
  task :rspec, [:rspec_args] do |_, args|
    KnapsackPro::Runners::RSpecRunner.run(args[:rspec_args])
  end

  # private
  task :rspec_test_example_detector do
    key = 'KNAPSACK_PRO_RSPEC_OPTIONS'
    raise "The internal #{key} environment variable is unset. Ensure it is not overridden accidentally. Otherwise, please report this as a bug: #{KnapsackPro::Urls::SUPPORT}" if ENV[key].nil?

    # Ignore `SPEC_OPTS` to not affect the RSpec execution within this rake task
    ENV.delete('SPEC_OPTS')

    KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector
      .new
      .calculate(ENV[key])
  end

  namespace :rspec do
    desc 'Precalculate Split by Test Examples into KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES_FILE (to avoid doing it later in each node running Knapsack Pro)'
    task :precalculate_split_by_test_examples, [:rspec_args] do |_, args|
      ENV['KNAPSACK_PRO_PRECALCULATING_SPLIT_BY_TEST_EXAMPLES'] = 'true'

      key = 'KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES_FILE'
      raise "Missing #{key}. See: #{KnapsackPro::Urls::SPLIT_BY_TEST_EXAMPLES_FILE}" if ENV[key].nil?

      ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec

      # Ignore `SPEC_OPTS` to not affect the RSpec execution within this rake task
      ENV.delete('SPEC_OPTS')

      KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector
        .new
        .calculate(args[:rspec_args].to_s)
    end
  end
end
