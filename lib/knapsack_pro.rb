require 'logger'
require 'singleton'
require 'net/http'
require 'json'
require 'uri'
require 'rake/testtask'
require_relative 'knapsack_pro/version'
require_relative 'knapsack_pro/credentials'
require_relative 'knapsack_pro/repository_adapters/git_adapter'
require_relative 'knapsack_pro/client/api/action'
require_relative 'knapsack_pro/client/api/v1/base'
require_relative 'knapsack_pro/client/api/v1/build_distributions'
require_relative 'knapsack_pro/client/connection'
require_relative 'knapsack_pro/config/env'
require_relative 'knapsack_pro/allocator'
require_relative 'knapsack_pro/allocator_builder'
#require_relative 'knapsack_pro/task_loader'
require_relative 'knapsack_pro/adapters/base_adapter'
require_relative 'knapsack_pro/adapters/rspec_adapter'
#require_relative 'knapsack_pro/adapters/cucumber_adapter'
#require_relative 'knapsack_pro/adapters/minitest_adapter'
require_relative 'knapsack_pro/runners/rspec_runner'
#require_relative 'knapsack_pro/runners/cucumber_runner'
#require_relative 'knapsack_pro/runners/minitest_runner'

module KnapsackPro
  class << self
    def root
      File.expand_path('../..', __FILE__)
    end

    def logger
      return @logger if @logger
      log = ::Logger.new(STDOUT)
      log.level = ::Logger::WARN
      @logger = log
    end

    def logger=(value)
      @logger = value
    end
  end
end
