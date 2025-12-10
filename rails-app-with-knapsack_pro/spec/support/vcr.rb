require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
end

require 'webmock/rspec'
WebMock.disable_net_connect! # Needed to test https://github.com/KnapsackPro/knapsack_pro-ruby/pull/251
