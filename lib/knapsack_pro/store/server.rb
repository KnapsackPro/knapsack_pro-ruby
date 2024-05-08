# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      def self.store_server_uri
        ENV['KNAPSACK_PRO_STORE_SERVER_URI']
      end

      # must be set in the main/parent process to make the env var available to the child process
      def self.set_available_store_server_uri
        DRb.start_service('druby://localhost:0')
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = DRb.uri
        DRb.stop_service
      end

      def self.start_server
        set_available_store_server_uri
        puts "URI: #{store_server_uri}"

        pid = fork do
          server_is_running = true

          Signal.trap("QUIT") {
            puts "#{self} forked process got QUIT signal."
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
      end

      def self.start_client
        # must be called at least once per process
        # https://ruby-doc.org/stdlib-2.7.0/libdoc/drb/rdoc/DRb.html
        #DRb.start_service

        server_uri = store_server_uri || raise("#{self} must be started first.")
        DRbObject.new_with_uri(server_uri)
      end

      def get_current_time
        @i ||= 0
        @i += 1
        puts @i

        Time.now
      end
    end
  end
end
