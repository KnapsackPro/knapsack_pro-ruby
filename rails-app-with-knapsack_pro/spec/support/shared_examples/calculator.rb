shared_examples 'has add method' do
  it 'add is true' do
    expect(subject.respond_to?(:add)).to be true
  end
end

shared_examples 'has mal method' do
  it 'mal is true' do
    expect(subject.respond_to?(:mal)).to be true
  end
end

shared_examples 'calculator' do
  it_behaves_like 'has add method'
  it_behaves_like 'has mal method'
end
