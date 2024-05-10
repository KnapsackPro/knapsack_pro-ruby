describe KnapsackPro::Store::Server do
  describe 'Queue test batches' do
    it do
      KnapsackPro::Store::Server.start
      store = KnapsackPro::Store::Server.client

      expect(store.batches).to eq []


      # 1st batch
      batched_tests_1 = ['a_spec.rb', 'b_spec.rb']
      store.add_batch(batched_tests_1)

      expect(store.batches.size).to eq 1
      expect(store.batches[0].test_file_paths).to eq(['a_spec.rb', 'b_spec.rb'])

      expect {
        store.batches[0].passed?
      }.to raise_error KnapsackPro::Store::TestsBatch::TestFilesNotExecutedError
      expect(store.batches[0].executed?).to be false

      store.last_batch_passed!

      expect(store.batches[0].passed?).to be true
      expect(store.batches[0].executed?).to be true


      # 2nd batch
      batched_tests_2 = ['c_spec.rb', 'd_spec.rb']
      store.add_batch(batched_tests_2)

      expect(store.batches.size).to eq 2
      expect(store.batches[1].test_file_paths).to eq(['c_spec.rb', 'd_spec.rb'])

      expect {
        store.batches[1].passed?
      }.to raise_error KnapsackPro::Store::TestsBatch::TestFilesNotExecutedError
      expect(store.batches[1].executed?).to be false

      store.last_batch_failed!

      expect(store.batches[1].passed?).to be false
      expect(store.batches[1].executed?).to be true
    end
  end
end
