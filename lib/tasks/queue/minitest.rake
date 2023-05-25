require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :minitest, [:minitest_args] do |_, args|
      # ENV['RAILS_ENV'] = ENV['RACK_ENV'] = 'test'
      sh "RAILS_ENV=test RACK_ENV=test bundle exec rake 'knapsack_pro:queue:minitest_go[#{args[:minitest_args]}]'"
    end

    task :minitest_go, [:minitest_args] do |_, args|
      KnapsackPro::Runners::Queue::MinitestRunner.run(args[:minitest_args])
    end
  end
end
