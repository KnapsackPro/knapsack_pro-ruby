require 'rspec/its'
require 'spinach'

require 'timecop'
Timecop.safe_mode = true

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'vcr'
require 'webmock/rspec'
VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock # or :fakeweb
  config.ignore_hosts('codeclimate.com')
end

require 'knapsack_pro'

Dir["#{KnapsackPro.root}/spec/{support,fixtures}/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.order = :random
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    if RSpec.current_example.metadata[:clear_tmp]
      FileUtils.mkdir_p(File.join(KnapsackPro.root, 'tmp'))
    end
  end

  config.after(:each) do
    if RSpec.current_example.metadata[:clear_tmp]
      FileUtils.rm_r(File.join(KnapsackPro.root, 'tmp'))
    end
  end
end
