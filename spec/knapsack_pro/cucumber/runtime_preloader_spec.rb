describe KnapsackPro::Cucumber::RuntimePreloader do
  describe '.reset_runtime_memoization' do
    it 'removes the memoized instance variables so a reused runtime rebuilds reports, formatters, and parsed features against the new configuration' do
      runtime = Object.new
      runtime.instance_variable_set(:@features, double)
      runtime.instance_variable_set(:@report, double)
      runtime.instance_variable_set(:@summary_report, double)
      runtime.instance_variable_set(:@support_code, support_code = double)

      described_class.reset_runtime_memoization(runtime)

      expect(runtime.instance_variable_defined?(:@features)).to be false
      expect(runtime.instance_variable_defined?(:@report)).to be false
      expect(runtime.instance_variable_defined?(:@summary_report)).to be false
      # the loaded support code (e.g. the booted Rails app) must be preserved
      expect(runtime.instance_variable_get(:@support_code)).to eq support_code
    end
  end
end
