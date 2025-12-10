ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# don't load this because it breaks CI
# require 'test/unit/rails/test_help'

# To use test-unit we need to ensure the minitest is not loaded
# because shoulda_test detect it.
# https://github.com/michaelgpearce/shared_should/blob/master/lib/shared_should/test_unit_hooks.rb
#
# minitest is loaded by rails so we need to fake it that it's not loaded
# so proper case will happen in share_should test_unit_hooks.rb
if defined?(MiniTest::Unit)
  Object.const_get('MiniTest::Unit').send(:remove_const, 'TestCase')
end

if defined?(MiniTest::Unit::TestCase)
  raise 'MiniTest should not be visible for share_should'
end

require 'shared_should'

require 'knapsack_pro'

# CUSTOM_CONFIG_GOES_HERE

knapsack_pro_adapter = KnapsackPro::Adapters::TestUnitAdapter.bind
knapsack_pro_adapter.set_test_helper_path(__FILE__)
