require 'rails'
require 'knapsack_pro'

module KnapsackPro
  class Railtie < Rails::Railtie
    rake_tasks do
      KnapsackPro.load_tasks
    end
  end
end
