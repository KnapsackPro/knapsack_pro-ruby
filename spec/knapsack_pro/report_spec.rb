describe KnapsackPro::Report do
  describe '.save' do
    subject { described_class.save }

    before do
      tracker = instance_double(KnapsackPro::Tracker, to_a: test_files)
      expect(KnapsackPro).to receive(:tracker).and_return(tracker)
    end

    context "when test files doesn't exist" do
      let(:test_files) { [] }

      it do
        logger = instance_double(Logger)
        expect(KnapsackPro).to receive(:logger).and_return(logger)
        expect(logger).to receive(:info).with("Didn't save time execution report on API server because there are no test files matching criteria on this node. Probably reason might be very narrowed tests list - you run only tests with specified tag and there are fewer test files with the tag than node total number.")
        subject
      end
    end

    context 'when test files exists' do
      let(:test_files) { [double] }

      before do
        commit_hash = double
        branch = double
        repository_adapter = instance_double(KnapsackPro::RepositoryAdapters::EnvAdapter, commit_hash: commit_hash, branch: branch)
        expect(KnapsackPro::RepositoryAdapterInitiator).to receive(:call).and_return(repository_adapter)

        node_total = double
        node_index = double
        expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(node_total)
        expect(KnapsackPro::Config::Env).to receive(:ci_node_index).and_return(node_index)

        action = double
        expect(KnapsackPro::Client::API::V1::BuildSubsets).to receive(:create).with({
          commit_hash: commit_hash,
          branch: branch,
          node_total: node_total,
          node_index: node_index,
          test_files: test_files,
        }).and_return(action)

        connection = instance_double(KnapsackPro::Client::Connection, success?: success?, errors?: errors?)
        expect(KnapsackPro::Client::Connection).to receive(:new).with(action).and_return(connection).and_return(connection)

        response = double
        expect(connection).to receive(:call).and_return(response)
      end

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
            expect(logger).to receive(:info).with('Saved time execution report on API server.')
            subject
          end
        end
      end

      context 'when failure' do
        let(:success?) { false }
        let(:errors?) { nil }

        it { subject }
      end
    end
  end
end
