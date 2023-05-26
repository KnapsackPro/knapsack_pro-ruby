require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :minitest, [:minitest_args] do |_, args|
      # ENV['RAILS_ENV'] = ENV['RACK_ENV'] = 'test'
      Kernel.system("RAILS_ENV=test RACK_ENV=test #{$PROGRAM_NAME} 'knapsack_pro:queue:minitest_go[#{args[:minitest_args]}]'")
      Kernel.exit($?.exitstatus)
    end

    task :minitest_go, [:minitest_args] do |_, args|
      KnapsackPro::Runners::Queue::MinitestRunner.run(args[:minitest_args])
    end
  end
end
