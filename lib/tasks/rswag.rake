require 'knapsack_pro'

namespace :knapsack_pro do
  task :rswag, [:rspec_args] do |_, args|
    KnapsackPro::Runners::RswagRunner.run(args[:rspec_args])
  end
end
