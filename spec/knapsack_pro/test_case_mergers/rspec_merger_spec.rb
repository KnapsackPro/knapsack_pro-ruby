describe KnapsackPro::TestCaseMergers::RSpecMerger do
  describe '#call' do
    subject { described_class.new(test_files).call }

    context 'when test files are regular file paths (not test example paths)' do
      let(:test_files) do
        [
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          { 'path' => 'spec/b_spec.rb', 'time_execution' => 2.2 },
        ]
      end

      it 'returns the test files unchanged' do
        expect(subject).to eq([
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          { 'path' => 'spec/b_spec.rb', 'time_execution' => 2.2 },
        ])
      end
    end

    context 'when test files have test example paths' do
      let(:test_files) do
        [
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          # test example paths
          { 'path' => 'spec/test_case_spec.rb[1:1]', 'time_execution' => 2.2 },
          { 'path' => 'spec/test_case_spec.rb[1:2]', 'time_execution' => 0.8 },
        ]
      end

      it 'merges the test example paths and sums their execution times' do
        expect(subject).to eq([
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          { 'path' => 'spec/test_case_spec.rb', 'time_execution' => 3.0 },
        ])
      end
    end

    context 'when test files have test example paths and the full test file path exists simultaneously' do
      let(:test_files) do
        [
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          # full test file path exists alongside test example paths
          { 'path' => 'spec/test_case_spec.rb', 'time_execution' => 1.0 },
          # test example paths
          { 'path' => 'spec/test_case_spec.rb[1:1]', 'time_execution' => 2.2 },
          { 'path' => 'spec/test_case_spec.rb[1:2]', 'time_execution' => 0.8 },
        ]
      end

      it 'merges the paths and sums their execution times' do
        expect(subject).to eq([
          { 'path' => 'spec/a_spec.rb', 'time_execution' => 1.1 },
          { 'path' => 'spec/test_case_spec.rb', 'time_execution' => 4.0 },
        ])
      end
    end
  end
end
