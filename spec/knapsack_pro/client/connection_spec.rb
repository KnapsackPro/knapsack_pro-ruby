describe KnapsackPro::Client::Connection do
  let(:endpoint_path) { '/v1/fake_endpoint' }
  let(:http_method) { :post }
  let(:request_hash) { { fake: 'hash' } }
  let(:action) do
    instance_double(KnapsackPro::Client::API::Action,
                    endpoint_path: endpoint_path,
                    http_method: http_method,
                    request_hash: request_hash)
  end

  let(:connection) { described_class.new(action) }

  before do
    stub_const('ENV', {
      'KNAPSACK_PRO_ENDPOINT' => 'http://api.knapsackpro.dev:3000',
      'KNAPSACK_PRO_TEST_SUITE_TOKEN' => '3fa64859337f6e56409d49f865d13fd7',
    })
  end

  describe '#call' do
    let(:logger) { instance_double(Logger) }

    subject { connection.call }

    context 'when http method is POST' do
      before do
        http = instance_double(Net::HTTP)

        expect(Net::HTTP).to receive(:new).with('api.knapsackpro.dev', 3000).and_return(http)

        expect(http).to receive(:use_ssl=).with(false)
        expect(http).to receive(:open_timeout=).with(15)
        expect(http).to receive(:read_timeout=).with(15)

        header = { 'X-Request-Id' => 'fake-uuid' }
        http_response = instance_double(Net::HTTPOK, body: body, header: header)
        expect(http).to receive(:post).with(
          endpoint_path,
          "{\"fake\":\"hash\",\"test_suite_token\":\"3fa64859337f6e56409d49f865d13fd7\"}",
          {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json',
            'KNAPSACK-PRO-CLIENT-NAME' => 'knapsack_pro-ruby',
            'KNAPSACK-PRO-CLIENT-VERSION' => KnapsackPro::VERSION,
          }
        ).and_return(http_response)
      end

      context 'when body response is json' do
        let(:body) { '{"errors": "value"}' }

        before do
          expect(KnapsackPro).to receive(:logger).exactly(3).and_return(logger)
          expect(logger).to receive(:debug).with('API request UUID: fake-uuid')
          expect(logger).to receive(:debug).with('API response:')
        end

        it do
          parsed_response = { 'errors' => 'value' }

          expect(logger).to receive(:error).with(parsed_response)

          expect(subject).to eq(parsed_response)
          expect(connection.success?).to be true
          expect(connection.errors?).to be true
        end
      end

      context 'when body response is json with build_distribution_id' do
        let(:body) { '{"build_distribution_id": "seed-uuid"}' }

        before do
          expect(KnapsackPro).to receive(:logger).exactly(4).and_return(logger)
          expect(logger).to receive(:debug).with('API request UUID: fake-uuid')
          expect(logger).to receive(:debug).with("Test suite split seed: seed-uuid")
          expect(logger).to receive(:debug).with('API response:')
        end

        it do
          parsed_response = { 'build_distribution_id' => 'seed-uuid' }

          expect(logger).to receive(:debug).with(parsed_response)

          expect(subject).to eq(parsed_response)
          expect(connection.success?).to be true
          expect(connection.errors?).to be false
        end
      end

      context 'when body response is empty' do
        let(:body) { '' }

        before do
          expect(KnapsackPro).to receive(:logger).exactly(3).and_return(logger)
          expect(logger).to receive(:debug).with('API request UUID: fake-uuid')
          expect(logger).to receive(:debug).with('API response:')
        end

        it do
          expect(logger).to receive(:debug).with('')

          expect(subject).to eq('')
          expect(connection.success?).to be true
          expect(connection.errors?).to be false
        end
      end
    end
  end

  describe '#success?' do
    subject { connection.success? }

    before do
      allow(connection).to receive(:response_body).and_return(response_body)
    end

    context 'when response has no value' do
      let(:response_body) { nil }

      it { should be false }
    end

    context 'when response has value' do
      let(:response_body) do
        { 'fake' => 'response' }
      end

      it { should be true }
    end
  end

  describe '#errors?' do
    subject { connection.errors? }

    before do
      allow(connection).to receive(:response_body).and_return(response_body)
    end

    context 'when response has no value' do
      let(:response_body) { nil }

      it { should be false }
    end

    context 'when response has value' do
      context 'when response has no errors' do
        let(:response_body) do
          { 'fake' => 'response' }
        end

        it { should be false }
      end

      context 'when response has errors' do
        let(:response_body) do
          { 'errors' => [{ 'field' => 'is wrong' }] }
        end

        it { should be true }
      end

      context 'when response has error (i.e. internal server error)' do
        let(:response_body) do
          { 'error' => 'Internal Server Error' }
        end

        it { should be true }
      end
    end
  end
end
