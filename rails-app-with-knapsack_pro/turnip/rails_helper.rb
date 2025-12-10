# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  if ENV['RSPEC_ORDER_RANDOM_DEFINED_IN_CONFIG']
    config.order = 'random'
  end

  config.infer_spec_type_from_file_location!

  config.include ActiveSupport::Testing::TimeHelpers

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
end
