describe Time do
  it do
    expect(Time.respond_to?(:now_without_mock)).to be true
  end
end
