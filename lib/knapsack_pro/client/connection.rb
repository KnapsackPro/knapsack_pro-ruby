module KnapsackPro
  module Client
    class Connection
      TIMEOUT = 5

      class << self
        def credentials
          @credentials ||= KnapsackPro::Credentials.new(:test_suite_token, :endpoint)
        end
      end

      def initialize(action)
        @action = action
      end

      def call
        send(action.http_method)
      end

      def success?
        !!response
      end

      def errors?
        !!(response && response['errors'])
      end

      private

      attr_reader :action, :response

      def logger
        KnapsackPro.logger
      end

      def credentials
        self.class.credentials.get
      end

      def endpoint
        credentials[:endpoint]
      end

      def endpoint_url
        endpoint + action.endpoint_path
      end

      def request_hash
        action
        .request_hash
        .merge({
          test_suite_token: test_suite_token
        })
      end

      def request_body
        request_hash.to_json
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
        return '' if body == '' || body.nil?
        JSON.parse(body)
      rescue JSON::ParserError
        nil
      end

      def post
        uri = URI.parse(endpoint_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        http_response = http.post(uri.path, request_body, json_headers)
        @response = parse_response(http_response.body)

        logger.error(response) if errors?

        response
      rescue Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
        logger.warn(e.inspect)
      end
    end
  end
end
