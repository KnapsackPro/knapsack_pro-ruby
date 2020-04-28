module KnapsackPro
  module Client
    class Connection
      class ServerError < StandardError; end

      TIMEOUT = 15
      MAX_RETRY = 3
      REQUEST_RETRY_TIMEBOX = 4

      def initialize(action)
        @action = action
      end

      def call
        send(action.http_method)
      end

      def success?
        return false if !response_body

        status = http_response.code.to_i
        status >= 200 && status < 500
      end

      def errors?
        !!(response_body && (response_body['errors'] || response_body['error']))
      end

      def server_error?
        status = http_response.code.to_i
        status >= 500 && status < 600
      end

      private

      attr_reader :action, :http_response, :response_body

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
          'Accept' => 'application/json',
          'KNAPSACK-PRO-CLIENT-NAME' => client_name,
          'KNAPSACK-PRO-CLIENT-VERSION' => KnapsackPro::VERSION,
        }
      end

      def client_name
        [
          'knapsack_pro-ruby',
          ENV['KNAPSACK_PRO_TEST_RUNNER'],
        ].compact.join('/')
      end

      def parse_response_body(body)
        return '' if body == '' || body.nil?
        JSON.parse(body)
      rescue JSON::ParserError
        nil
      end

      def seed
        return if @response_body.nil? || @response_body == ''
        response_body['build_distribution_id']
      end

      def has_seed?
        !seed.nil?
      end

      def make_request(&block)
        retries ||= 0

        @http_response = block.call
        @response_body = parse_response_body(http_response.body)

        request_uuid = http_response.header['X-Request-Id'] || 'N/A'

        logger.debug("API request UUID: #{request_uuid}")
        logger.debug("Test suite split seed: #{seed}") if has_seed?
        logger.debug('API response:')
        if errors?
          logger.error(response_body)
        else
          logger.debug(response_body)
        end

        if server_error?
          raise ServerError.new(response_body)
        end

        response_body
      rescue ServerError, Errno::ECONNREFUSED, Errno::ETIMEDOUT, Errno::EPIPE, EOFError, SocketError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
        logger.warn(e.inspect)
        retries += 1
        if retries < MAX_RETRY
          wait = retries * REQUEST_RETRY_TIMEBOX
          logger.warn("Wait #{wait}s and retry request to Knapsack Pro API.")
          Kernel.sleep(wait)
          retry
        else
          response_body
        end
      end

      def build_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = (uri.scheme == 'https')
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT
        http
      end

      def post
        uri = URI.parse(endpoint_url)
        http = build_http(uri)
        make_request do
          http.post(uri.path, request_body, json_headers)
        end
      end

      def get
        uri = URI.parse(endpoint_url)
        uri.query = URI.encode_www_form(request_hash)
        http = build_http(uri)
        make_request do
          http.get(uri, json_headers)
        end
      end
    end
  end
end
