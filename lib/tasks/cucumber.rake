# frozen_string_literal: true

require 'knapsack_pro'

namespace :knapsack_pro do
  task :cucumber, [:cucumber_args] do |_, args|
    KnapsackPro::Runners::CucumberRunner.run(args[:cucumber_args])
  end

  # private
  task :cucumber_test_example_detector do
    key = 'KNAPSACK_PRO_CUCUMBER_OPTIONS'
    raise "The internal #{key} environment variable is unset. Ensure it is not overridden accidentally. Otherwise, please report this as a bug: #{KnapsackPro::Urls::SUPPORT}" if ENV[key].nil?

    # The adapter bound in the support code (e.g., features/support/env.rb) must not
    # register time tracking hooks or save a report to the API during the dry run.
    ENV.delete('KNAPSACK_PRO_REGULAR_MODE_ENABLED')
    ENV.delete('KNAPSACK_PRO_QUEUE_MODE_ENABLED')

    KnapsackPro::TestCaseDetectors::CucumberTestExampleDetector
      .new
      .dry_run_to_file(ENV[key])
  end
end
