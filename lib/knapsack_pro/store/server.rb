# frozen_string_literal: true

module KnapsackPro
  module Store
    class Server
      def self.start_server
        DRb.start_service('druby://localhost:0', new)
        ENV['KNAPSACK_PRO_STORE_SERVER_URI'] = DRb.uri
        DRb.stop_service

        pid = fork do
          server_is_running = true

          Signal.trap("QUIT") {
            puts 'Forked process QUIT'
            server_is_running = false
          }

          begin
            DRb.start_service(ENV['KNAPSACK_PRO_STORE_SERVER_URI'], new)

            # Wait for the drb server thread to finish before exiting.
            #DRb.thread.join

            while server_is_running
              sleep 0.1
            end
          rescue Interrupt
            puts "Interrupt signal catched."
          ensure
            puts "Stopping DRb service."
            DRb.stop_service
          end
        end
      end

      def get_current_time
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
