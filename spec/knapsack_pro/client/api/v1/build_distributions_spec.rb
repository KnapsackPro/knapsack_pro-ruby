describe KnapsackPro::Client::API::V1::BuildDistributions do
  describe '.last' do
    it do
      actual = described_class.last(key: 'value')

      expect(actual.endpoint_path).to eq '/v1/build_distributions/last'
      expect(actual.http_method).to eq :get
      expect(actual.request_hash).to eq(key: 'value')
    end
  end
end
