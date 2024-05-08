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

      batched_tests_1 = ['a_spec.rb', 'b_spec.rb']
      store.add_batch_of_tests(batched_tests_1)

      batched_tests_2 = ['c_spec.rb', 'd_spec.rb']
      store.add_batch_of_tests(batched_tests_2)

      expect(store.queue_batches).to eq([
        ['a_spec.rb', 'b_spec.rb'],
        ['c_spec.rb', 'd_spec.rb']
      ])

      #sleep 200
      #sleep 10
      puts 'Almost done'
      sleep 1

    ensure
      Process.kill('QUIT', server_pid)
    end
  end
end
