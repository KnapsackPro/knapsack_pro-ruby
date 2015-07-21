require 'knapsack_pro'

namespace :knapsack_pro do
  task :rspec, [:rspec_args] do |_, args|
    KnapsackPro::Runners::RSpecRunner.run(args[:rspec_args])
  end
end
