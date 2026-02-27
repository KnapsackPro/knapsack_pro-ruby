require 'knapsack_pro'
require_relative '../../../lib/knapsack_pro/rspec/test_queue_initializer'
require 'json'

ENV['KNAPSACK_PRO_TEST_SUITE_TOKEN'] = SecureRandom.hex
ENV['KNAPSACK_PRO_TEST_QUEUE_ID'] = SecureRandom.uuid
ENV['KNAPSACK_PRO_TEST_DIR'] = 'spec_integration'
ENV['KNAPSACK_PRO_TEST_FILE_PATTERN'] = "spec_integration/**{,/*/**}/*_spec.rb"

RSPEC_OPTIONS = ENV.fetch('TEST__RSPEC_OPTIONS')

module Net
  class HTTP
    def get(path, headers)
      hash = {
        test_files: [
          { "path" => "spec_integration/fast_spec.rb", "time_execution" => 1 },
          { "path" => "spec_integration/slow_spec.rb", "time_execution" => 10 }
        ],
      }
      Net::HTTPOK.new("1.1", "200", "OK").tap do |response|
        response.body = JSON.dump(hash)
        response.instance_variable_set(:@read, true)
      end
    end

    def post(path, body, headers)
      puts body
      hash = {}
      # Return url if it's the initialize request (second one)
      hash.merge!(url: "http://example.com") if JSON.parse(body).key?("test_files")
      Net::HTTPOK.new("1.1", "200", "OK").tap do |response|
        response.body = JSON.dump(hash)
        response.instance_variable_set(:@read, true)
      end
    end
  end
end

module KnapsackProExtensions
  module RSpecTestExampleDetector
    def dry_run(*)
      examples = [
        { id: "spec_integration/fast_spec.rb[1:1]" },
        { id: "spec_integration/fast_spec.rb[1:2]" },
        { id: "spec_integration/slow_spec.rb[1:1]" },
        { id: "spec_integration/slow_spec.rb[1:2]" }
      ]
      File.write(report_path, { examples: examples }.to_json)
      0
    end
  end
end

KnapsackPro::TestCaseDetectors::RSpecTestExampleDetector.prepend(KnapsackProExtensions::RSpecTestExampleDetector)

KnapsackPro::RSpec::TestQueueInitializer.new.call(RSPEC_OPTIONS)
