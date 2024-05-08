describe KnapsackPro::Store::Server do
  it do
    Signal.trap("INT") {
      puts 'INT handler in spec.'
      exit
    }

    begin
      server_pid = KnapsackPro::Store::Server.start_server
      puts "fork PID: #{server_pid}"

      store = KnapsackPro::Store::Server.start_client

      #require 'pry'; binding.pry

      sleep 2

      puts store.get_current_time
      puts store.get_current_time


      store = KnapsackPro::Store::Server.start_client
      puts store.get_current_time
      puts store.get_current_time

      #sleep 200
      #sleep 10
      puts 'Almost done'
      sleep 1

    ensure
      Process.kill('QUIT', server_pid)
    end
  end
end
