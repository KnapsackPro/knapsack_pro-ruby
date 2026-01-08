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
      .dry_run_to_file(ENV[key])
  end
end
