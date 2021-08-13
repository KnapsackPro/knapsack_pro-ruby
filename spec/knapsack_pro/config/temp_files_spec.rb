describe KnapsackPro::Config::TempFiles, :clear_tmp do
  describe '.temp_directory_path' do
    let(:gitignore_file_path) { '.knapsack_pro/.gitignore' }

    subject { described_class.temp_directory_path }

    it 'returns temporary directory path' do
      expect(subject).to eq '.knapsack_pro'
    end

    it 'creates .gitignore file' do
      expect(File.exists?(gitignore_file_path)).to be false
      subject
      expect(File.exists?(gitignore_file_path)).to be true
    end

    it '.gitignore file has content' do
      subject
      expect(File.read(gitignore_file_path)).to include '# This directory is used by knapsack_pro gem for storing temporary files during tests runtime'
    end
  end
end
