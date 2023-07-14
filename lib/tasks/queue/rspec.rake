require 'knapsack_pro'

namespace :knapsack_pro do
  namespace :queue do
    task :rspec, [:rspec_args] do |_, args|
      Kernel.system("RAILS_ENV=test RACK_ENV=test #{$PROGRAM_NAME} 'knapsack_pro:queue:rspec_go[#{args[:rspec_args]}]'")
      exitstatus = $?.exitstatus
      if exitstatus.nil?
        puts 'Something went wrong. Most likely process has been killed.'
        Kernel.exit(1)
      else
        Kernel.exit(exitstatus)
      end
    end

    task :rspec_go, [:rspec_args] do |_, args|
      KnapsackPro::Runners::Queue::RSpecRunner.run(args[:rspec_args])
    end
  end
end
