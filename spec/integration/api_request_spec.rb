describe 'API Request Integration' do
  let(:valid_endpoint) { 'http://api.knapsackpro.dev:3000' }
  let(:invalid_endpoint) { 'http://api.fake-knapsackpro.dev:3000' }
  let(:valid_test_suite_token) { '3fa64859337f6e56409d49f865d13fd7' }
  let(:invalid_test_suite_token) { 'fake' }

  before do
    KnapsackPro::Client::Connection.credentials.set = {
      endpoint: endpoint,
      test_suite_token: test_suite_token
    }
  end

  context 'when success' do
    let(:endpoint) { valid_endpoint }
    let(:test_suite_token) { valid_test_suite_token }

    it do
      connection = KnapsackPro::Client::Connection.new(:node_tests)
      response = connection.post
      puts response

      expect(connection.errors?).to be false
    end
  end

  context 'when failure' do
    context 'when invalid test suite token' do

    end

    context 'when timeout' do

    end
  end
end
