describe KnapsackPro::Store::Server do
  it do
    KnapsackPro::Store::Server.start

    store = KnapsackPro::Store::Server.client

    expect(store.queue_batches).to eq []


    batched_tests_1 = ['a_spec.rb', 'b_spec.rb']
    store.queue_batch_manager.add_batch(batched_tests_1)
    store.add_files(batched_tests_1)

    batched_tests_2 = ['c_spec.rb', 'd_spec.rb']
    store.queue_batch_manager.add_batch(batched_tests_2)
    store.add_files(batched_tests_2)

    #require 'pry'; binding.pry

    expect(store.files).to eq([
      ['a_spec.rb', 'b_spec.rb'],
      ['c_spec.rb', 'd_spec.rb']
    ])

    expect(store.queue_batches).to eq([
      ['a_spec.rb', 'b_spec.rb'],
      ['c_spec.rb', 'd_spec.rb']
    ])
  end
end
