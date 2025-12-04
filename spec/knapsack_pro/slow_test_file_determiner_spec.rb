describe KnapsackPro::SlowTestFileDeterminer do
  describe '.call' do
    let(:node_total) { 4 }

    before do
      expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(node_total)
    end

    subject { described_class.call(test_files) }

    context 'when test files have recorded execution time' do
      let(:test_files) do
        [
          { 'path' => 'a_spec.rb', 'time_execution' => 1.0 },
          { 'path' => 'b_spec.rb', 'time_execution' => 3.4 },
          { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
          { 'path' => 'd_spec.rb', 'time_execution' => 12.1 },
        ]
      end

      it 'detects slow tests above 3.5s threshold (20.0 / 4 nodes * 70% threshold = 3.5)' do
        expect(subject).to eq([
          { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
          { 'path' => 'd_spec.rb', 'time_execution' => 12.1 },
        ])
      end
    end

    context 'when test files have recorded execution time AND slow test files threshold is set' do
      let(:test_files) do
        [
          { 'path' => 'a_spec.rb', 'time_execution' => 1.0 },
          { 'path' => 'b_spec.rb', 'time_execution' => 3.4 },
          { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
          { 'path' => 'd_spec.rb', 'time_execution' => 12.1 },
        ]
      end

      before do
        stub_const("ENV", { 'KNAPSACK_PRO_SLOW_TEST_FILE_THRESHOLD' => '2' })
      end

      it 'detects slow tests above 2.0s threshold' do
        expect(subject).to eq([
          { 'path' => 'b_spec.rb', 'time_execution' => 3.4 },
          { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
          { 'path' => 'd_spec.rb', 'time_execution' => 12.1 },
        ])
      end
    end

    context 'when test files have no recorded execution time' do
      let(:test_files) do
        [
          { 'path' => 'a_spec.rb', 'time_execution' => 0.0 },
          { 'path' => 'b_spec.rb', 'time_execution' => 0.0 },
        ]
      end

      it do
        expect(subject).to eq([])
      end
    end

    context 'when there are no test files' do
      let(:test_files) { [] }

      it do
        expect(subject).to eq([])
      end
    end
  end
end
