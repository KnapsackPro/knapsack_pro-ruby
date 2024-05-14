describe KnapsackPro::Store::Server do
  before do
    KnapsackPro::Store::Server.reset
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


        # verify public API for the gem users works
        expect(KnapsackPro::Store::Client.batches.size).to eq 2
        expect(KnapsackPro::Store::Client.batches[0].test_file_paths).to eq(['a_spec.rb', 'b_spec.rb'])
        expect(KnapsackPro::Store::Client.batches[1].test_file_paths).to eq(['c_spec.rb', 'd_spec.rb'])
      end
    end

    context 'when there is a delay in starting server in a forked process' do
      before do
        KnapsackPro::Store::Server.send(:assign_available_store_server_uri)
      end

      context 'when the delay is below 3 seconds' do
        it 'connects with the store server correctly' do
          thread = Thread.new do
            sleep 2
            KnapsackPro::Store::Server.start
          end

          store = KnapsackPro::Store::Server.client
          expect(store.ping).to be true

          thread.join
        end
      end

      context 'when the delay is above 3 seconds' do
        it do
          thread = Thread.new do
            sleep 4
            KnapsackPro::Store::Server.start
          end

          expect {
            KnapsackPro::Store::Server.client
          }.to raise_error DRb::DRbConnError

          thread.join
        end
      end
    end

    context 'when the server has not been started' do
      it do
        expect {
          KnapsackPro::Store::Server.client
        }.to raise_error RuntimeError, 'KNAPSACK_PRO_STORE_SERVER_URI must be set to available DRb port.'
      end
    end
  end
end
