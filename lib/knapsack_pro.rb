require_relative 'knapsack_pro/version'

module KnapsackPro
  class << self
    def root
      File.expand_path('../..', __FILE__)
    end
  end
end
