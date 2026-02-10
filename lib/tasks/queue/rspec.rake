# frozen_string_literal: true

require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :rspec, [:rspec_args] do |_, args|
      Kernel.exec("RAILS_ENV=test RACK_ENV=test #{$PROGRAM_NAME} 'knapsack_pro:queue:rspec_go[#{args[:rspec_args]}]'")
    end

    task :rspec_go, [:rspec_args] do |_, args|
      Rake::Task.clear
      KnapsackPro::Runners::Queue::RSpecRunner.run(args[:rspec_args])
    end

    namespace :rspec do
      desc 'Initialize the test queue to be consumed later.'
      task :initialize, [:rspec_args] do |_, args|
        require_relative '../../knapsack_pro/rspec/test_queue_initializer'

        ENV.delete('SPEC_OPTS') # Ignore `SPEC_OPTS` to not affect the RSpec execution within this rake task
        ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = KnapsackPro::Config::Env.test_suite_token_rspec

        KnapsackPro::RSpec::TestQueueInitializer.new.call(args[:rspec_args].to_s)
      end
    end
  end
end
