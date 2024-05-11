# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      extend Forwardable

      def self.start
        return unless @server_pid.nil?

        assign_store_server_uri

        @server_pid = fork do
          server_is_running = true

          Signal.trap("TERM") {
            server_is_running = false
          }

          DRb.start_service(store_server_uri, new)

          while server_is_running
            sleep 0.1
          end

          DRb.stop_service

          # Wait for the drb server thread to finish before exiting.
          DRb.thread&.join
        end

        ::Kernel.at_exit do
          stop
        end
      end

      def self.stop
        return if @server_pid.nil?
        Process.kill('TERM', @server_pid)
        Process.waitpid2(@server_pid)
        @server_pid = nil
      rescue Errno::ESRCH # process does not exist
        @server_pid = nil
      end

      def self.client
        @client ||=
          begin
            retries ||= 0

            # must be called at least once per process
            # https://ruby-doc.org/stdlib-2.7.0/libdoc/drb/rdoc/DRb.html
            DRb.start_service

            server_uri = store_server_uri || raise("#{self} must be started first.")
            client = DRbObject.new_with_uri(server_uri)
            client.ping
            client
          rescue DRb::DRbConnError
            wait_seconds = 0.1
            retries += wait_seconds
            sleep wait_seconds
            retry if retries <= 3 # seconds
            raise
          end
      end

      def_delegators :@queue_batch_manager, :add_batch, :last_batch_passed!, :last_batch_failed!, :batches

      def initialize
        reset
      end

      def reset
        @queue_batch_manager = KnapsackPro::Store::QueueBatchManager.new
      end

      def ping
        true
      end

      private

      def self.store_server_uri
        ENV['KNAPSACK_PRO_STORE_SERVER_URI']
      end

      # must be set in the main/parent process to make the env var available to the child process
      def self.assign_store_server_uri
        @uri ||=
          begin
            DRb.start_service('druby://localhost:0')
            uri = DRb.uri
            ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = uri
            DRb.stop_service
            uri
          end
      end
    end
  end
end
