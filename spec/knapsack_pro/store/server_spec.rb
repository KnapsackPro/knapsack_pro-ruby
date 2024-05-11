describe KnapsackPro::Store::Server do
  before do
    KnapsackPro::Store::Server.stop
  end

  describe 'Queue test batches' do
    context 'when the queue mode flow' do
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
        }.to raise_error KnapsackPro::Store::TestBatch::TestFilesNotExecutedError
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
        }.to raise_error KnapsackPro::Store::TestBatch::TestFilesNotExecutedError
        expect(store.batches[1].executed?).to be false

        store.last_batch_failed!

        expect(store.batches[1].passed?).to be false
        expect(store.batches[1].executed?).to be true
      end
    end

    context 'when there is a delay in starting service in a forked process' do
      context 'when the delay is below 3 seconds' do
        before do
          KnapsackPro::Store::Server.send(:assign_store_server_uri)

          Thread.new do
            sleep 2
            KnapsackPro::Store::Server.start
          end
        end
        after do
          KnapsackPro::Store::Server.stop
        end

        it 'connects with the store server correctly' do
          store = KnapsackPro::Store::Server.client
          expect(store.ping).to be true
        end
      end

      context 'when the delay is above 3 seconds' do
        before do
          KnapsackPro::Store::Server.send(:assign_store_server_uri)
        end

        it do
          expect {
            KnapsackPro::Store::Server.client
          }.to raise_error DRb::DRbConnError
        end
      end
    end
  end
end
