shared_examples 'slow shared example test' do
  it do
    sleep 1.5
    expect(true).to be true
  end
end
