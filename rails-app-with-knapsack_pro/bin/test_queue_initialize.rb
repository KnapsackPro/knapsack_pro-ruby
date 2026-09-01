require "net/http"
require "uri"
require "json"

test_queue_id = ARGV[0]

endpoint = "http://api.knapsackpro.localhost:3000"
uri = URI("#{endpoint}/v2/test_queues/#{test_queue_id}")
token = "a28ce51204d7c7dbd25c3352fea222cf"
max_node_total = 10

body = {
  branch: `git branch --show-current`.chomp,
  commit_hash: `git rev-parse head`.chomp,
  max_node_total: max_node_total,
  paths: Dir.glob("spec/**/*_spec.rb")
}

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")

request = Net::HTTP::Put.new(uri)
request["Content-Type"] = "application/json"
request["Accept"] = "application/json"
request["KNAPSACK-PRO-TEST-SUITE-TOKEN"] = token
request.body = body.to_json

require "zlib"
request["Content-Encoding"] = "gzip"
request.body = Zlib.gzip(body.to_json, level: Zlib::BEST_COMPRESSION)

response = http.request(request)

puts response.code
puts response.body
