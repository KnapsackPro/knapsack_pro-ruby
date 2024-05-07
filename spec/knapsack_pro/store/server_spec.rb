describe KnapsackPro::Store::Server do
  it do
    Signal.trap("INT") {
      puts 'INT handler in spec.'
      exit
    }

    _server_uri = KnapsackPro::Store::Server.start_server
    store = KnapsackPro::Store::Server.start_client

    sleep 2

    puts store.get_current_time

    #sleep 200
    sleep 10
    puts 'Almost done'
    sleep 1
  end
end
