# frozen_string_literal: true

require "json"
require "net/http"

module KnapsackPro
  class RetryFailedTests
    def initialize(branch)
      @branch = branch || `git branch --show-current`.chomp
    end

    def call(runner_args)
      $stderr.puts "Branch: #{branch}"

      failed_paths = fetch_failed_paths
      return ($stderr.puts "Nothing to run") if failed_paths.size.zero?

      $stderr.puts "Retrying #{failed_paths.size} tests..."
      exec Gem.bin_path("rspec-core", "rspec"), *(runner_args + failed_paths)
    end

    private

    attr_accessor :branch

    def fetch_failed_paths
      headers = {
        'Accept' => 'application/json',
        'KNAPSACK-PRO-TEST-SUITE-TOKEN' => ENV.fetch("KNAPSACK_PRO_TEST_SUITE_TOKEN")
      }

      uri = URI.parse("#{KnapsackPro::Config::Env.endpoint}/v2/test_paths")
      uri.query = URI.encode_www_form(branch: KnapsackPro::Crypto::BranchEncryptor.call(branch))

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.open_timeout = 5
      http.read_timeout = 5

      response = http.get(uri.request_uri, headers)
      abort response.inspect if (300..).cover?(response.code.to_i)

      parsed = JSON.parse(response.body)
      abort parsed.inspect if parsed['errors']

      parsed.fetch('failed_paths')
    end
  end
end
