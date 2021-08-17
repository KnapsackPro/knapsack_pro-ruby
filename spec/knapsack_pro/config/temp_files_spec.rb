describe KnapsackPro::Config::TempFiles, :clear_tmp do
  describe 'TEMP_DIRECTORY_PATH' do
    subject { described_class::TEMP_DIRECTORY_PATH }

    it 'returns temporary directory path' do
      expect(subject).to eq '.knapsack_pro'
    end
  end

  describe '.ensure_temp_directory_exists!' do
    let(:gitignore_file_path) { '.knapsack_pro/.gitignore' }

    subject { described_class.ensure_temp_directory_exists! }

    it 'creates .gitignore file' do
      expect(File.exist?(gitignore_file_path)).to be false
      subject
      expect(File.exist?(gitignore_file_path)).to be true
    end

    it '.gitignore file has content' do
      subject

      expect(File.read(gitignore_file_path)).to include '# This directory is used by knapsack_pro gem for storing temporary files during tests runtime'
      expect(File.read(gitignore_file_path)).to include '# Ignore all files, and do not commit this directory into your repository.'
      expect(File.read(gitignore_file_path)).to include '# Learn more at https://knapsackpro.com'
      expect(File.read(gitignore_file_path)).to include '*'
    end
  end
end
