require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :minitest, [:minitest_args] do |_, args|
      KnapsackPro::Runners::Queue::MinitestRunner.run(args[:minitest_args])
    end
  end
end
