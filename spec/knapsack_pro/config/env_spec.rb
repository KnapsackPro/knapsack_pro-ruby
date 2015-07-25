describe KnapsackPro::Config::Env do
  describe '.ci_node_total' do
    subject { described_class.ci_node_total }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_TOTAL has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_TOTAL' => 5 }) }
        it { should eql 5 }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_total).and_return(4)
        end

        it { should eql 4 }
      end
    end

    context "when ENV doesn't exist" do
      it { should eql 1 }
    end
  end

  describe '.ci_node_index' do
    subject { described_class.ci_node_index }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_INDEX has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_INDEX' => 3 }) }
        it { should eql 3 }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_index).and_return(2)
        end

        it { should eql 2 }
      end
    end

    context "when ENV doesn't exist" do
      it { should eql 0 }
    end
  end

  describe '.commit_hash' do
    subject { described_class.commit_hash }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_COMMIT_HASH has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_COMMIT_HASH' => '3fa64859337f6e56409d49f865d13fd7' }) }
        it { should eql '3fa64859337f6e56409d49f865d13fd7' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:commit_hash).and_return('fe61a08118d0d52e97c38666eba1eaf3')
        end

        it { should eql 'fe61a08118d0d52e97c38666eba1eaf3' }
      end
    end

    context "when ENV doesn't exist" do
      it { should be nil }
    end
  end

  describe '.branch' do
    subject { described_class.branch }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_BRANCH has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_BRANCH' => 'master' }) }
        it { should eql 'master' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:branch).and_return('feature-branch')
        end

        it { should eql 'feature-branch' }
      end
    end

    context "when ENV doesn't exist" do
      it { should be nil }
    end
  end

  describe '.project_dir' do
    subject { described_class.project_dir }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_PROJECT_DIR has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_PROJECT_DIR' => '/home/user/myapp' }) }
        it { should eql '/home/user/myapp' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:project_dir).and_return('/home/runner/myapp')
        end

        it { should eql '/home/runner/myapp' }
      end
    end

    context "when ENV doesn't exist" do
      it { should be nil }
    end
  end

  describe '.test_file_pattern' do
    subject { described_class.test_file_pattern }

    context 'when ENV exists' do
      let(:test_file_pattern) { 'custom_spec/**/*_spec.rb' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_PATTERN' => test_file_pattern }) }
      it { should eql test_file_pattern }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.ci_env_for' do
    let(:env_name) { :node_total }

    subject { described_class.ci_env_for(env_name) }

    context 'when CI has no value for env_name method' do
      before do
        expect(KnapsackPro::Config::CI::Circle).to receive_message_chain(:new, env_name).and_return(nil)
        expect(KnapsackPro::Config::CI::Semaphore).to receive_message_chain(:new, env_name).and_return(nil)
        expect(KnapsackPro::Config::CI::Buildkite).to receive_message_chain(:new, env_name).and_return(nil)
      end

      it do
        expect(subject).to be_nil
      end
    end

    context 'when CI has value for env_name method' do
      let(:circle_env) { double(:circle) }
      let(:semaphore_env) { double(:semaphore) }
      let(:buildkite_env) { double(:buildkite) }

      before do
        allow(KnapsackPro::Config::CI::Circle).to receive_message_chain(:new, env_name).and_return(circle_env)
        allow(KnapsackPro::Config::CI::Semaphore).to receive_message_chain(:new, env_name).and_return(semaphore_env)
        allow(KnapsackPro::Config::CI::Buildkite).to receive_message_chain(:new, env_name).and_return(buildkite_env)
      end

      it { should eq circle_env }

      context do
        let(:circle_env) { nil }

        it { should eq semaphore_env }
      end

      context do
        let(:circle_env) { nil }
        let(:semaphore_env) { nil }

        it { should eq buildkite_env }
      end
    end
  end
end
