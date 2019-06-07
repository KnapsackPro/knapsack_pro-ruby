require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :cucumber, [:cucumber_args] do |_, args|
      KnapsackPro::Runners::Queue::CucumberRunner.run(args[:cucumber_args])
    end
  end
end
