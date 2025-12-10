describe Calculator do
  it_behaves_like 'calculator'

  describe '#add' do
    it do
      expect(subject.add(2, 3)).to eq 5
    end
  end

  describe '#mal' do
    it do
      expect(subject.mal(2, 3)).to eq 6
    end
  end
end
