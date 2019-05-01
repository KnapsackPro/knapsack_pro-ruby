describe KnapsackPro::Report do
  describe '.save' do
    subject { described_class.save }

    it do
      test_files = [double]
      tracker = instance_double(KnapsackPro::Tracker, to_a: test_files)
      expect(KnapsackPro).to receive(:tracker).and_return(tracker)
      expect(described_class).to receive(:create_build_subset).with(test_files)

      subject
    end
  end

  describe '.save_subset_queue_to_file' do
    let(:fake_path) { SecureRandom.uuid }

    subject { described_class.save_subset_queue_to_file }

    before do
      test_files = [{path: fake_path}]
      tracker = instance_double(KnapsackPro::Tracker, to_a: test_files)
      expect(KnapsackPro).to receive(:tracker).and_return(tracker)

      subset_queue_id = 'fake-subset-queue-id'
      expect(KnapsackPro::Config::Env).to receive(:subset_queue_id).and_return(subset_queue_id)

      queue_id = 'fake-queue-id'
      expect(KnapsackPro::Config::Env).to receive(:queue_id).twice.and_return(queue_id)
    end

    it do
      subject

      expect(
        JSON.parse(
          File.read('tmp/knapsack_pro/queue/fake-queue-id/fake-subset-queue-id.json')
        )
      ).to eq([
        { 'path' => fake_path }
      ])
    end
  end

  describe '.save_node_queue_to_api' do
    context 'when json files with recorded time exist for executed test files' do
      let(:json_test_file_a_path) { double }
      let(:json_test_file_a) { [{ 'path' => 'a_spec.rb' }] }

      let(:json_test_file_b_path) { double }
      let(:json_test_file_b) { [{ 'path' => 'b_spec.rb' }] }

      let(:executed_test_files_count) { 2 }

      subject { described_class.save_node_queue_to_api(executed_test_files_count) }

      before do
        queue_id = 'fake-queue-id'
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)

        expect(Dir).to receive(:glob).with('tmp/knapsack_pro/queue/fake-queue-id/*.json').and_return([
          json_test_file_a_path,
          json_test_file_b_path
        ])

        expect(File).to receive(:read).with(json_test_file_a_path).and_return(json_test_file_a.to_json)
        expect(File).to receive(:read).with(json_test_file_b_path).and_return(json_test_file_b.to_json)
      end

      it 'creates build subset for 2 recorded test files timing' do
        expect(described_class).to receive(:create_build_subset).with(
          json_test_file_a + json_test_file_b
        )

        subject
      end
    end

    context 'when json files with recorded time does not exist for executed test files' do
      let(:executed_test_files_count) { 2 }

      subject { described_class.save_node_queue_to_api(executed_test_files_count) }

      before do
        queue_id = 'fake-queue-id'
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)

        expect(Dir).to receive(:glob).with('tmp/knapsack_pro/queue/fake-queue-id/*.json').and_return([])
      end

      it 'logs error on lost info about recorded timing for test files due missing json files AND creates empty build subset' do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:error).with('2 test files were executed on this CI node but the recorded time of it was lost. Probably you have a code (i.e. RSpec hooks) that clears tmp directory in your project. Please ensure you do not remove the content of tmp/knapsack_pro/queue/ directory between tests run.')

        expect(described_class).to receive(:create_build_subset).with([])

        subject
      end
    end

    context 'when json files with recorded time does not exist AND no executed test files' do
      let(:executed_test_files_count) { 0 }

      subject { described_class.save_node_queue_to_api(executed_test_files_count) }

      before do
        queue_id = 'fake-queue-id'
        expect(KnapsackPro::Config::Env).to receive(:queue_id).and_return(queue_id)

        expect(Dir).to receive(:glob).with('tmp/knapsack_pro/queue/fake-queue-id/*.json').and_return([])
      end

      it 'logs warning about reasons why no test files were executed on this CI node' do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).exactly(3).and_return(logger)
        expect(logger).to receive(:warn).with('No test files were executed on this CI node.')
        expect(logger).to receive(:debug).with('When you use knapsack_pro queue mode then probably reason might be that CI node was started after the test files from the queue were already executed by other CI nodes. That is why this CI node has no test files to execute.')
        expect(logger).to receive(:debug).with("Another reason might be when your CI node failed in a way that prevented knapsack_pro to save time execution data to Knapsack Pro API and you have just tried to retry failed CI node but instead you got no test files to execute. In that case knapsack_pro don't know what testes should be executed here.")

        expect(described_class).to receive(:create_build_subset).with([])

        subject
      end
    end
  end

  describe '.create_build_subset' do
    subject { described_class.create_build_subset(test_files) }

    before do
      commit_hash = double
      branch = double
      repository_adapter = instance_double(KnapsackPro::RepositoryAdapters::EnvAdapter, commit_hash: commit_hash, branch: branch)
      expect(KnapsackPro::RepositoryAdapterInitiator).to receive(:call).and_return(repository_adapter)

      unsymbolize_test_files = double
      expect(KnapsackPro::Utils).to receive(:unsymbolize).with(test_files).and_return(unsymbolize_test_files)

      encrypted_test_files = double
      expect(KnapsackPro::Crypto::Encryptor).to receive(:call).with(unsymbolize_test_files).and_return(encrypted_test_files)

      encrypted_branch = double
      expect(KnapsackPro::Crypto::BranchEncryptor).to receive(:call).with(repository_adapter.branch).and_return(encrypted_branch)

      node_total = double
      node_index = double
      expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(node_total)
      expect(KnapsackPro::Config::Env).to receive(:ci_node_index).and_return(node_index)

      action = double
      expect(KnapsackPro::Client::API::V1::BuildSubsets).to receive(:create).with({
        commit_hash: commit_hash,
        branch: encrypted_branch,
        node_total: node_total,
        node_index: node_index,
        test_files: encrypted_test_files,
      }).and_return(action)

      connection = instance_double(KnapsackPro::Client::Connection, success?: success?, errors?: errors?)
      expect(KnapsackPro::Client::Connection).to receive(:new).with(action).and_return(connection).and_return(connection)

      response = double
      expect(connection).to receive(:call).and_return(response)
    end

    shared_examples_for 'create_build_subset method' do
      context 'when success' do
        let(:success?) { true }

        context 'when response has errors' do
          let(:errors?) { true }

          it do
            expect {
              subject
            }.to raise_error(ArgumentError)
          end
        end

        context 'when response has no errors' do
          let(:errors?) { false }

          it do
            logger = instance_double(Logger)
            expect(KnapsackPro).to receive(:logger).and_return(logger)
            expect(logger).to receive(:debug).with('Saved time execution report on Knapsack Pro API server.')
            subject
          end
        end
      end

      context 'when failure' do
        let(:success?) { false }
        let(:errors?) { nil }

        it do
          logger = instance_double(Logger)
          expect(KnapsackPro).to receive(:logger).and_return(logger)
          expect(logger).to receive(:warn).with('Time execution report was not saved on Knapsack Pro API server due to connection problem.')
          subject
        end
      end
    end

    context "when test files doesn't exist" do
      let(:test_files) { [] }

      it_behaves_like 'create_build_subset method'
    end

    context 'when test files exists' do
      let(:test_files) { [double] }

      it_behaves_like 'create_build_subset method'
    end
  end
end
