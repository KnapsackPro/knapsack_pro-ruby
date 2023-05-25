require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :rspec, [:rspec_args] do |_, args|
      # ENV['RAILS_ENV'] = ENV['RACK_ENV'] = 'test'
      sh "RAILS_ENV=test RACK_ENV=test bundle exec rake 'knapsack_pro:queue:rspec_go[#{args[:rspec_args]}]'"
    end

    task :rspec_go, [:rspec_args] do |_, args|
      KnapsackPro::Runners::Queue::RSpecRunner.run(args[:rspec_args])
    end
  end
end
