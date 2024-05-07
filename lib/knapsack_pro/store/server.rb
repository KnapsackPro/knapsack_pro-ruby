# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      def self.start_server
        DRb.start_service('druby://localhost:0', new)
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = DRb.uri

        pid = fork do
          server_is_running = true

          Signal.trap("QUIT") {
            puts 'Forked process QUIT'
            server_is_running = false
          }

          DRb.start_service(ENV['KNAPSACK_PRO_STORE_SERVER_URI'], new)

          while server_is_running
            sleep 0.1
          end

          DRb.stop_service

          # Wait for the drb server thread to finish before exiting.
          DRb.thread&.join
        end
      end

      def get_current_time
        @i ||= 0
        @i += 1
        puts @i

        Time.now
      end

      def self.start_client
        # must be called at least once per process
        # https://ruby-doc.org/stdlib-2.7.0/libdoc/drb/rdoc/DRb.html
        DRb.start_service

        server_uri = ENV['KNAPSACK_PRO_STORE_SERVER_URI'] || raise("#{self} must be started first.")
        DRbObject.new_with_uri(server_uri)
      end
    end
  end
end
