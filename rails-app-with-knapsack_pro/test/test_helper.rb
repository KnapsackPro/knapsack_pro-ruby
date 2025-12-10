ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/spec'

require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE
KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  print '-'*10
  print 'Before Queue Hook - run before the test suite'
  print '-'*10
end

KnapsackPro::Hooks::Queue.before_subset_queue do |queue_id, subset_queue_id|
  print '-'*10
  print 'Before Subset Queue Hook - run before the next subset of tests'
  print '-'*10
end

KnapsackPro::Hooks::Queue.after_subset_queue do |queue_id, subset_queue_id|
  print '-'*10
  print 'After Subset Queue Hook - run after the previous subset of tests'
  print '-'*10
end

KnapsackPro::Hooks::Queue.after_queue do |queue_id|
  print '-'*10
  print 'After Queue Hook - run after the test suite'
  print '-'*10
end

knapsack_pro_adapter = KnapsackPro::Adapters::MinitestAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)

require 'simplecov'

if ENV['CI']
  require 'simplecov_json_formatter'
  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end

SimpleCov.start

KnapsackPro::Hooks::Queue.before_queue do |queue_id|
  SimpleCov.command_name("minitest_ci_node_#{KnapsackPro::Config::Env.ci_node_index}")
end

KnapsackPro::Hooks::Queue.after_queue do
  SimpleCov.result.format!
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  extend Minitest::Spec::DSL

  # Allow context to be used like describe
  # This is needed to make minitest spec context work
  # in test/minitest/meme_spec_test.rb
  class << self
    alias :context :describe
  end

  register_spec_type(self) do |desc|
    desc < ActiveRecord::Base if desc.is_a?(Class)
  end
end

class Minitest::SharedExamples < Module
  include Minitest::Spec::DSL
end

SharedExampleSpec = Minitest::SharedExamples.new do
  def setup
    sleep 0.1
  end

  def test_mal
    sleep 0.1
    assert_equal 4, 2 * 2
  end

  def test_no_way
    sleep 0.2
    refute_match(/^no/i, 'yes')
  end

  def test_that_will_be_skipped
    skip 'test this later'
  end
end
