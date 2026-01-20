require "open3"
require "knapsack_pro/commands"
require "knapsack_pro/commands/retry_failed_tests"

describe "commands" do
  describe "retry" do
    around(:each) do |example|
      original = $stderr
      $stderr = StringIO.new
      example.run
      $stdout = original
    end

    it do
      body = JSON.dump(failed_paths: ["spec/a_spec.rb[1:2:3]"])
      response = instance_double(Net::HTTPResponse, code: "200", body: body)
      expect_any_instance_of(Net::HTTP).to receive(:get) do |_klass, path, headers|
        expect(path).to eq("/v2/test_paths?branch=feature")
        expect(headers).to include("KNAPSACK-PRO-TEST-SUITE-TOKEN" => "abc:123")
        response
      end

      expect_any_instance_of(Kernel).to receive(:exec) do |_klass, bin, *args|
        expect(bin).to include("rspec")
        expect(args).to eq(["--formatter", "progress", "spec/a_spec.rb[1:2:3]"])
      end

      env = { "KNAPSACK_PRO_TEST_SUITE_TOKEN" => "abc:123" }
      stub_const("ENV", env)

      cmd = ["retry", "--branch", "feature", "--", "--formatter", "progress"]
      KnapsackPro::Commands.start(cmd)
    end
  end
end
