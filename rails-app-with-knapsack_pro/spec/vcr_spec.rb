describe 'VCR' do
  it do
    VCR.use_cassette("synopsis") do
      response = Net::HTTP.get_response(URI('http://www.iana.org/domains/reserved'))
       expect(response.body).to include('Example domains')
    end
  end
end
