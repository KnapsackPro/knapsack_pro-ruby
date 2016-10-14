module KnapsackPro
  module Client
    class Connection
      TIMEOUT = 15

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
        !!(response && (response['errors'] || response['error']))
      end

      private

      attr_reader :action, :response

      def logger
        KnapsackPro.logger
      end

      def endpoint
        KnapsackPro::Config::Env.endpoint
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
        KnapsackPro::Config::Env.test_suite_token
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

      def seed
        return if @response.nil? || @response == ''
        response['build_distribution_id']
      end

      def has_seed?
        !seed.nil?
      end

      def post
        uri = URI.parse(endpoint_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        http_response = http.post(uri.path, request_body, json_headers)
        @response = parse_response(http_response.body)

        request_uuid = http_response.header['X-Request-Id']

        logger.info("API request UUID: #{request_uuid}")
        logger.info("Test suite split seed: #{seed}") if has_seed?
        logger.info('API response:')
        if errors?
          logger.error(response)
        else
          logger.info(response)
        end

        response
      rescue Errno::ECONNREFUSED, EOFError, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        logger.warn(e.inspect)
      end
    end
  end
end
