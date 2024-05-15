# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      extend Forwardable

      def self.reset
        stop
        set_store_server_uri(nil)
        @assigned_store_server_uri = nil
        @client = nil
      end

      def self.start
        return unless @server_pid.nil?

        assign_available_store_server_uri

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

      def self.client
        return @client unless @client.nil?

        # must be called at least once per process
        # https://ruby-doc.org/stdlib-2.7.0/libdoc/drb/rdoc/DRb.html
        DRb.start_service

        @client = DRbObject.new_with_uri(store_server_uri)

        begin
          retries ||= 0
          @client.ping
          @client
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
        @queue_batch_manager = KnapsackPro::Store::QueueBatchManager.new
      end

      def ping
        true
      end

      private

      def self.stop
        return if @server_pid.nil?
        Process.kill('TERM', @server_pid)
        Process.waitpid2(@server_pid)
        @server_pid = nil
      rescue Errno::ESRCH # process does not exist
        @server_pid = nil
      end

      def self.set_store_server_uri(uri)
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = uri
      end

      def self.store_server_uri
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] || raise("KNAPSACK_PRO_STORE_SERVER_URI must be set to available DRb port.")
      end

      # must be set in the main/parent process to make the env var available to the child process
      def self.assign_available_store_server_uri
        @assigned_store_server_uri ||=
          begin
            find_available_drb_port_for_dummy_service
            set_store_server_uri(DRb.uri)
            stop_dummy_service
            true
          end
      end

      def self.find_available_drb_port_for_dummy_service
        DRb.start_service('druby://localhost:0')
      end

      def self.stop_dummy_service
        DRb.stop_service
      end
    end
  end
end
