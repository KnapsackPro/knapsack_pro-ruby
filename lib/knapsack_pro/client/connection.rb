module KnapsackPro
  module Client
    class Connection
      TIMEOUT = 5

      MAP = {
        node_tests: {
          endpoint_path: '/v1/build_distributions/subset',
          request_builder: KnapsackPro::Client::API::V1::BuildDistributions,
          request_action: :subset,

        }
      }

      class << self
        def credentials
          @credentials ||= KnapsackPro::Credentials.new(:test_suite_token, :endpoint)
        end
      end

      def initialize(key)
        request_details = MAP[key] || raise('Wrong action')
        @endpoint_path = request_details[:endpoint_path]
        @request_builder = request_details[:request_builder]
        @request_action = request_details[:request_action]
      end

      def post
        uri = URI.parse(endpoint_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        http_response = http.post(uri.path, request_hash.to_json, json_headers)
        @response = parse_response(http_response.body)

        logger.error(response) if errors?

        response
      rescue Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
        logger.warn(e.pretty_inspect)
      end

      def errors?
        !!response['errors']
      end

      private

      attr_reader :response,
        :endpoint_path,
        :request_builder,
        :request_action

      def logger
        KnapsackPro.logger
      end

      def credentials
        self.class.credentials.get
      end

      def endpoint_url
        endpoint + endpoint_path
      end

      def endpoint
        credentials[:endpoint]
      end

      def request_hash
        request_builder
        .send(request_action)
        .merge({
          test_suite_token: test_suite_token
        })
      end

      def test_suite_token
        credentials[:test_suite_token]
      end

      def json_headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end

      def parse_response(body)
        JSON.parse(body)
      end
    end
  end
end
