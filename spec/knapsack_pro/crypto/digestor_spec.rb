describe KnapsackPro::Crypto::Digestor do
  describe '.salt_hexdigest' do
    let(:path) { 'a_spec.rb' }

    subject { described_class.salt_hexdigest(path) }

    before do
      expect(KnapsackPro::Config::Env).to receive(:salt).at_least(1).and_return('123')
    end

    it { should eq '93131469d5aee8158473f9945847cd411ba975644b617897b7c33164adc55038' }
  end
end
