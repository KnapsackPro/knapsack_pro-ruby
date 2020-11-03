describe KnapsackPro::TestFileCleaner do
  describe '.clean' do
    subject { described_class.clean(test_file_path) }

    context "removes ./ " do
      let(:test_file_path) { './models/user_spec.rb' }
      it 'removes ./ from the begining of the test file path' do
        expect(subject).to eq 'models/user_spec.rb'
      end
    end

    context "removes , " do
      let(:test_file_path) { 'models/user_spec.rb,' }
      it 'removes , from the end of the test file path' do
        expect(subject).to eq 'models/user_spec.rb'
      end
    end
  end
end
