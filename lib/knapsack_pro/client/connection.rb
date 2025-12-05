# frozen_string_literal: true

require 'stringio'

module KnapsackPro
  module Client
    class Connection
      class ServerError < StandardError; end

      TIMEOUT = 15
      REQUEST_RETRY_TIMEBOX = 8

      def initialize(action)
        @action = action
        @http_debug_output = StringIO.new
      end

      def call
        send(action.http_method)
      end

      def success?
        return false unless response_body

        status = http_response.code.to_i
        status >= 200 && status < 500
      end

      def errors?
        !!(response_body && (response_body['errors'] || response_body['error']))
      end

      def api_code
        return unless response_body

        response_body['code']
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

      def endpoint_uri
        URI.parse(KnapsackPro::Config::Env.endpoint + action.endpoint_path)
      end

      def json_headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'KNAPSACK-PRO-CLIENT-NAME' => client_name,
          'KNAPSACK-PRO-CLIENT-VERSION' => KnapsackPro::VERSION,
          'KNAPSACK-PRO-TEST-SUITE-TOKEN' => KnapsackPro::Config::Env.test_suite_token,
          'KNAPSACK-PRO-CI-PROVIDER' => KnapsackPro::Config::Env.ci_provider
        }.compact
      end

      def client_name
        [
          'knapsack_pro-ruby',
          ENV['KNAPSACK_PRO_TEST_RUNNER']
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

      def make_request(&block)
        retries ||= 0

        @http_response = block.call
        @response_body = parse_response_body(http_response.body)

        request_uuid = http_response.header['X-Request-Id'] || 'N/A'

        logger.debug("#{action.http_method.to_s.upcase} #{endpoint_uri}")
        logger.debug("API request UUID: #{request_uuid}")
        logger.debug("Test suite split seed: #{seed}") unless seed.nil?
        logger.debug('API response:')
        if errors?
          logger.error(response_body)
        else
          logger.debug(response_body)
        end

        raise ServerError.new(response_body) if server_error?

        response_body
      rescue ServerError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, Errno::EPIPE, EOFError,
             SocketError, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError => e
        retries += 1
        log_diagnostics(e, retries)
        @http.set_debug_output(@http_debug_output) if retries == max_request_retries - 1
        if retries < max_request_retries
          backoff(retries)
          rotate_ip
          retry
        else
          response_body
        end
      end

      def log_diagnostics(error, retries)
        message = [
          action.http_method.to_s.upcase,
          endpoint_uri,
          @http.ipaddr # value from @http.ipaddr= or nil
        ].compact.join(' ')
        logger.warn(message)
        logger.warn('Request failed due to:')
        logger.warn(error.inspect)
        return if retries < max_request_retries

        logger.warn('Net::HTTP debug output:')
        @http_debug_output.string.each_line { |line| logger.warn(line.chomp) }
        logger.warn

        require 'open3'
        error.backtrace.each { |line| logger.warn(line) }
        [
          "dig #{endpoint_uri.host}",
          "nslookup #{endpoint_uri.host}",
          "curl -v #{endpoint_uri.host}:#{endpoint_uri.port}",
          "nc -vz #{endpoint_uri.host} #{endpoint_uri.port}",
          "openssl s_client -connect #{endpoint_uri.host}:#{endpoint_uri.port} < /dev/null",
          'env'
        ].each do |cmd|
          logger.warn
          logger.warn(cmd)
          logger.warn('=' * cmd.size)
          begin
            outerr, status = Open3.capture2e(cmd)
            logger.warn("Exit status: #{status.exitstatus}")
            outerr.each_line { |line| logger.warn(line.chomp) }
          rescue Errno::ENOENT => e
            logger.warn("Error: #{e}")
          end
          logger.warn
        end
      end

      def backoff(retries)
        wait = retries * REQUEST_RETRY_TIMEBOX
        print_every = 2 # seconds
        (wait / print_every).ceil.times do |i|
          if i.zero?
            logger.warn("Wait for #{wait}s before retrying the request to the Knapsack Pro API.")
          else
            logger.warn("#{wait - i * print_every}s left before retry...")
          end
          Kernel.sleep(print_every)
        end
      end

      def build_http(uri)
        @http = net_http.new(uri.host, uri.port)
        @http.use_ssl = (uri.scheme == 'https')
        @http.open_timeout = TIMEOUT
        @http.read_timeout = TIMEOUT
        rotate_ip
      end

      def rotate_ip
        # Ruby v3.4 implements Happy Eyeballs Version 2 (RFC 8305)
        return if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.4')

        @ipaddrs ||=
          begin
            require 'resolv'
            resolvers = [
              Resolv::Hosts.new,
              Resolv::DNS.new(Resolv::DNS::Config.default_config_hash.merge(use_ipv6: false))
            ]
            Resolv.new(resolvers).getaddresses(endpoint_uri.host).shuffle
          end

        @http.ipaddr = @ipaddrs.rotate!.first
      end

      def net_http
        if defined?(WebMock::HttpLibAdapters::NetHttpAdapter::OriginalNetHTTP)
          WebMock::HttpLibAdapters::NetHttpAdapter::OriginalNetHTTP
        else
          Net::HTTP
        end
      end

      def post
        build_http(endpoint_uri)
        make_request do
          @http.post(endpoint_uri.path, action.request_hash.to_json, json_headers)
        end
      end

      def get
        uri = endpoint_uri
        uri.query = URI.encode_www_form(action.request_hash)
        build_http(uri)
        make_request do
          @http.get(uri, json_headers)
        end
      end

      def max_request_retries
        # when user defined max request retries
        return KnapsackPro::Config::Env.max_request_retries if KnapsackPro::Config::Env.max_request_retries

        # when Fallback Mode is disabled then try more attempts to connect to the API
        return 6 unless KnapsackPro::Config::Env.fallback_mode_enabled?

        # when Regular Mode then try more attempts to connect to the API
        # if only one CI node starts Fallback Mode instead of all then we can't guarantee all test files will be run
        # https://github.com/KnapsackPro/knapsack_pro-ruby/pull/124
        return 6 if KnapsackPro::Config::Env.regular_mode?

        # default number of attempts
        3
      end
    end
  end
end
