require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :rspec, [:rspec_args] do |_, args|
      KnapsackPro::Runners::Queue::RSpecRunner.run(args[:rspec_args])
    end
  end
end
