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
    described_class.credentials.set = {
      test_suite_token: '3fa64859337f6e56409d49f865d13fd7',
      endpoint: 'http://api.knapsackpro.dev:3000'
    }
  end

  describe '#call' do
    subject { connection.call }

    context 'when http method is POST' do
      it do
        http = instance_double(Net::HTTP)

        expect(Net::HTTP).to receive(:new).with('api.knapsackpro.dev', 3000).and_return(http)

        expect(http).to receive(:open_timeout=).with(5)
        expect(http).to receive(:read_timeout=).with(5)

        http_response = instance_double(Net::HTTPOK, body: '{"errors": "value"}')
        expect(http).to receive(:post).with(
          endpoint_path,
          "{\"fake\":\"hash\",\"test_suite_token\":\"3fa64859337f6e56409d49f865d13fd7\"}",
          { "Content-Type" => "application/json", "Accept" => "application/json" }
        ).and_return(http_response)

        parsed_response = { 'errors' => 'value' }
        expect(KnapsackPro.logger).to receive(:error).with(parsed_response)

        expect(subject).to eq(parsed_response)
      end
    end
  end

  describe '#success?' do
    subject { connection.success? }

    before do
      allow(connection).to receive(:response).and_return(response)
    end

    context 'when response has no value' do
      let(:response) { nil }

      it { should be false }
    end

    context 'when response has value' do
      let(:response) do
        { 'fake' => 'response' }
      end

      it { should be true }
    end
  end

  describe '#errors?' do
    subject { connection.errors? }

    before do
      allow(connection).to receive(:response).and_return(response)
    end

    context 'when response has no value' do
      let(:response) { nil }

      it { should be false }
    end

    context 'when response has value' do
      context 'when response has errors' do
        let(:response) do
          { 'fake' => 'response' }
        end

        it { should be false }
      end

      context 'when response has no errors' do
        let(:response) do
          { 'errors' => [{ 'field' => 'is wrong' }] }
        end

        it { should be true }
      end
    end
  end
end
