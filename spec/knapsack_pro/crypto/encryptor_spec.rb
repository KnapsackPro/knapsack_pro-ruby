describe KnapsackPro::Crypto::Encryptor do
  let(:test_files) do
    [
      { path: 'a_spec.rb', time_execution: 1.2 },
      { path: 'b_spec.rb', time_execution: 2.3 },
    ]
  end

  let(:encryptor) { described_class.new(test_files) }

  describe '#call' do
    subject { encryptor.call }

    before do
      expect(KnapsackPro::Config::Env).to receive(:salt).at_least(1).and_return('123')
    end

    it "should not modify input test files array" do
      test_files_original = Marshal.load(Marshal.dump(test_files))
      subject
      expect(test_files).to eq test_files_original
    end

    it do
      should eq([
        { path: '93131469d5aee8158473f9945847cd411ba975644b617897b7c33164adc55038', time_execution: 1.2 },
        { path: '716143a50194e2d2173b757b3418564f5efd12ce3c52332c02db60bb70c240bc', time_execution: 2.3 },
      ])
    end
  end
end
