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

  describe '.save_to_json_report' do
    let(:test_files) do
      [
        { 'path' => 'a_spec.rb', 'time_execution' => 1.0 },
        # unique path to ensure we saved on disk a completely new report
        { 'path' => "#{SecureRandom.hex}_spec.rb", 'time_execution' => 3.4 },
      ]
    end

    subject { described_class.save_to_json_report(test_files) }

    it do
      json_report_path = 'tmp/knapsack_pro/slow_test_file_determiner/slow_test_files.json'
      subject
      expect(File.exists?(json_report_path)).to be true
      expect(File.read(json_report_path)).to eq(test_files.to_json)
    end
  end
end
