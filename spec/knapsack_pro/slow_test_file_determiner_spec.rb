describe KnapsackPro::SlowTestFileDeterminer do
  describe '.call' do
    let(:node_total) { 4 }
    let(:time_execution) { 20.0 }
    let(:test_files) do
      [
        { 'path' => 'a_spec.rb', 'time_execution' => 1.0 },
        { 'path' => 'b_spec.rb', 'time_execution' => 3.4 },
        # slow tests are above 3.5s threshold (20.0 / 4 * 0.7 = 3.5)
        { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
        { 'path' => 'd_spec.rb', 'time_execution' => 5.9 },
      ]
    end

    before do
      expect(KnapsackPro::Config::Env).to receive(:ci_node_total).and_return(node_total)
    end

    subject { described_class.call(test_files, time_execution) }

    it do
      expect(subject).to eq([
        { 'path' => 'c_spec.rb', 'time_execution' => 3.5 },
        { 'path' => 'd_spec.rb', 'time_execution' => 5.9 },
      ])
    end
  end
end
