describe KnapsackPro::Config::Env do
  before { stub_const("ENV", {}) }

  describe '.ci_node_total' do
    subject { described_class.ci_node_total }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_TOTAL has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_TOTAL' => '5' }) }
        it { should eq 5 }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_total).and_return(4)
        end

        it { should eq 4 }
      end

      context 'when both KNAPSACK_PRO_CI_NODE_TOTAL and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_TOTAL' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:node_total).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '5' }
          let(:ci_value) { 4 }

          it { should eq 5 }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_CI_NODE_TOTAL to 5 which could be automatically determined from the CI environment as 4.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '5' }
          let(:ci_value) { 5 }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should eq 1 }
    end
  end

  describe '.ci_node_index' do
    subject { described_class.ci_node_index }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_INDEX has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_INDEX' => '3' }) }
        it { should eq 3 }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_index).and_return(2)
        end

        it { should eq 2 }
      end

      context 'when both KNAPSACK_PRO_CI_NODE_INDEX and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_INDEX' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:node_index).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '3' }
          let(:ci_value) { 2 }

          it { should eq 3 }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_CI_NODE_INDEX to 3 which could be automatically determined from the CI environment as 2.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '3' }
          let(:ci_value) { 3 }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end

      context 'when order of loading envs does matter' do
        context 'when GitLab CI' do
          before { stub_const("ENV", { 'CI_NODE_INDEX' => '2', 'GITLAB_CI' => 'true' }) }
          it { should eq 1 }
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should eq 0 }
    end
  end

  describe '.ci_node_build_id' do
    subject { described_class.ci_node_build_id }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_BUILD_ID has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_BUILD_ID' => '7' }) }
        it { should eq '7' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_build_id).and_return('8')
        end

        it { should eq '8' }
      end

      context 'when both KNAPSACK_PRO_CI_NODE_BUILD_ID and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_BUILD_ID' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:node_build_id).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '7' }
          let(:ci_value) { '8' }

          it { should eq '7' }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_CI_NODE_BUILD_ID to 7 which could be automatically determined from the CI environment as 8.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '7' }
          let(:ci_value) { '7' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end
    end

    context "when ENV does not exist" do
      it 'raises' do
        expect { subject }.to raise_error(/Missing environment variable KNAPSACK_PRO_CI_NODE_BUILD_ID/)
      end
    end
  end

  describe '.ci_node_retry_count' do
    subject { described_class.ci_node_retry_count }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_CI_NODE_RETRY_COUNT has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_RETRY_COUNT' => '1' }) }
        it { should eq 1 }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:node_retry_count).and_return('2')
        end

        it { should eq 2 }
      end

      context 'when both KNAPSACK_PRO_CI_NODE_RETRY_COUNT and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_CI_NODE_RETRY_COUNT' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:node_retry_count).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '1' }
          let(:ci_value) { 2 }

          it { should eq 1 }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_CI_NODE_RETRY_COUNT to 1 which could be automatically determined from the CI environment as 2.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '7' }
          let(:ci_value) { '7' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should eq 0 }
    end
  end

  describe '.max_request_retries' do
    subject { described_class.max_request_retries }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_MAX_REQUEST_RETRIES' => '2' }) }
      it { should eq 2 }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.commit_hash' do
    subject { described_class.commit_hash }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_COMMIT_HASH has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_COMMIT_HASH' => '3fa64859337f6e56409d49f865d13fd7' }) }
        it { should eq '3fa64859337f6e56409d49f865d13fd7' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:commit_hash).and_return('fe61a08118d0d52e97c38666eba1eaf3')
        end

        it { should eq 'fe61a08118d0d52e97c38666eba1eaf3' }
      end

      context 'when both KNAPSACK_PRO_COMMIT_HASH and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_COMMIT_HASH' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:commit_hash).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '3fa64859337f6e56409d49f865d13fd7' }
          let(:ci_value) { 'fe61a08118d0d52e97c38666eba1eaf3' }

          it { should eq '3fa64859337f6e56409d49f865d13fd7' }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_COMMIT_HASH to 3fa64859337f6e56409d49f865d13fd7 which could be automatically determined from the CI environment as fe61a08118d0d52e97c38666eba1eaf3.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '3fa64859337f6e56409d49f865d13fd7' }
          let(:ci_value) { '3fa64859337f6e56409d49f865d13fd7' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
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
        it { should eq 'master' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:branch).and_return('feature-branch')
        end

        it { should eq 'feature-branch' }
      end

      context 'when both KNAPSACK_PRO_BRANCH and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_BRANCH' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:branch).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { 'master' }
          let(:ci_value) { 'feature-branch' }

          it { should eq 'master' }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_BRANCH to master which could be automatically determined from the CI environment as feature-branch.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { 'master' }
          let(:ci_value) { 'master' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
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
        it { should eq '/home/user/myapp' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:project_dir).and_return('/home/runner/myapp')
        end

        it { should eq '/home/runner/myapp' }
      end

      context 'when both KNAPSACK_PRO_PROJECT_DIR and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_PROJECT_DIR' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:project_dir).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { '/home/user/myapp' }
          let(:ci_value) { '/home/runner/myapp' }

          it { should eq '/home/user/myapp' }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_PROJECT_DIR to /home/user/myapp which could be automatically determined from the CI environment as /home/runner/myapp.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { '/home/user/myapp' }
          let(:ci_value) { '/home/user/myapp' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should be nil }
    end
  end

  describe '.user_seat' do
    subject { described_class.user_seat }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_USER_SEAT has value' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_USER_SEAT' => 'John Doe' }) }
        it { should eq 'John Doe' }
      end

      context 'when CI environment has value' do
        before do
          expect(described_class).to receive(:ci_env_for).with(:user_seat).and_return('Jane Doe')
        end

        it { should eq 'Jane Doe' }
      end

      context 'when both KNAPSACK_PRO_USER_SEAT and CI environment have value' do
        let(:logger) { instance_double(Logger, info: nil) }

        before do
          stub_const("ENV", { 'KNAPSACK_PRO_USER_SEAT' => env_value })
          expect(described_class).to receive(:ci_env_for).with(:user_seat).and_return(ci_value)
          allow(KnapsackPro).to receive(:logger).and_return(logger)
        end

        context 'when values are different' do
          let(:env_value) { 'John Doe' }
          let(:ci_value) { 'Jane Doe' }

          it { should eq 'John Doe' }

          it 'logs a warning' do
            expect(logger).to receive(:info).with(
              'You have set the environment variable KNAPSACK_PRO_USER_SEAT to John Doe which could be automatically determined from the CI environment as Jane Doe.'
            )
            subject
          end
        end

        context 'when values are the same' do
          let(:env_value) { 'John Doe' }
          let(:ci_value) { 'John Doe' }

          it 'does not log a warning' do
            expect(logger).not_to receive(:info)
            subject
          end
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should be nil }
    end
  end

  describe '.masked_seat_hash' do
    subject { described_class.masked_user_seat }

    before do
      expect(described_class).to receive(:user_seat).at_least(1).and_return(user_seat)
    end

    context 'when the user seat is a name' do
      let(:user_seat) { 'John Doe' }

      it { expect(subject).to eq 'Jo** Do*' }
    end

    context 'when the user seat is an e-mail' do
      let(:user_seat) { 'john.doe@example.com' }

      it { expect(subject).to eq 'jo**.do*@ex*****.co*' }
    end

    context 'when the user seat is nil' do
      let(:user_seat) { nil }

      it { expect(subject).to be_nil }
    end
  end

  describe '.test_file_pattern' do
    subject { described_class.test_file_pattern }

    context 'when ENV exists' do
      let(:test_file_pattern) { 'custom_spec/**{,/*/**}/*_spec.rb' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_PATTERN' => test_file_pattern }) }
      it { should eq test_file_pattern }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.slow_test_file_pattern' do
    subject { described_class.slow_test_file_pattern }

    context 'when ENV exists' do
      let(:slow_test_file_pattern) { 'spec/features/*_spec.rb' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_SLOW_TEST_FILE_PATTERN' => slow_test_file_pattern }) }
      it { should eq slow_test_file_pattern }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_file_exclude_pattern' do
    subject { described_class.test_file_exclude_pattern }

    context 'when ENV exists' do
      let(:test_file_exclude_pattern) { 'spec/features/*_spec.rb' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_EXCLUDE_PATTERN' => test_file_exclude_pattern }) }
      it { should eq test_file_exclude_pattern }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_file_list' do
    subject { described_class.test_file_list }

    context 'when ENV exists' do
      let(:test_file_list) { 'spec/features/dashboard_spec.rb,spec/models/user.rb:10,spec/models/user.rb:29' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_LIST' => test_file_list }) }
      it { should eq test_file_list }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_file_list_source_file' do
    subject { described_class.test_file_list_source_file }

    context 'when ENV exists' do
      let(:test_file_list_source_file) { 'spec/fixtures/test_file_list_source_file.txt' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILE_LIST_SOURCE_FILE' => test_file_list_source_file }) }
      it { should eq test_file_list_source_file }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_dir' do
    subject { described_class.test_dir }

    context 'when ENV exists' do
      let(:test_dir) { 'spec' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_DIR' => test_dir }) }
      it { should eql test_dir }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.repository_adapter' do
    subject { described_class.repository_adapter }

    context 'when ENV exists' do
      let(:repository_adapter) { 'git' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_REPOSITORY_ADAPTER' => repository_adapter }) }
      it { should eq repository_adapter }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.regular_mode?' do
    subject { described_class.regular_mode? }

    context 'when regular mode is enabled' do
      let(:regular_mode_enabled) { 'true' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_REGULAR_MODE_ENABLED' => regular_mode_enabled }) }
      it { should eq true }
    end

    context 'when regular mode is disabled' do
      let(:regular_mode_enabled) { 'false' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_REGULAR_MODE_ENABLED' => regular_mode_enabled }) }
      it { should eq false }
    end

    context "when ENV doesn't exist" do
      it { should false }
    end
  end

  describe '.queue_mode?' do
    subject { described_class.queue_mode? }

    context 'when queue mode is enabled' do
      let(:queue_mode_enabled) { 'true' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_QUEUE_MODE_ENABLED' => queue_mode_enabled }) }
      it { should eq true }
    end

    context 'when queue mode is disabled' do
      let(:queue_mode_enabled) { 'false' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_QUEUE_MODE_ENABLED' => queue_mode_enabled }) }
      it { should eq false }
    end

    context "when ENV doesn't exist" do
      it { should false }
    end
  end

  describe '.queue_id' do
    subject { described_class.queue_id }

    context 'when ENV exists' do
      let(:queue_id) { 'fake-queue-id' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_QUEUE_ID' => queue_id }) }
      it { should eq queue_id }
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it do
        expect { subject }.to raise_error('Missing Queue ID')
      end
    end
  end

  describe '.subset_queue_id' do
    subject { described_class.subset_queue_id }

    context 'when ENV exists' do
      let(:subset_queue_id) { 'fake-subset-queue-id' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_SUBSET_QUEUE_ID' => subset_queue_id }) }
      it { should eq subset_queue_id }
    end

    context "when ENV doesn't exist" do
      it do
        expect { subject }.to raise_error('Missing Subset Queue ID')
      end
    end
  end

  describe '.fallback_mode_enabled' do
    subject { described_class.fallback_mode_enabled }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_FALLBACK_MODE_ENABLED' => 'false' }) }
      it { should eq 'false' }
    end

    context "when ENV doesn't exist" do
      it { should be true }
    end
  end

  describe '.fallback_mode_enabled?' do
    subject { described_class.fallback_mode_enabled? }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_FALLBACK_MODE_ENABLED' => 'false' }) }
      it { should be false }
    end

    context "when ENV doesn't exist" do
      it { should be true }
    end
  end

  describe '.test_files_encrypted' do
    subject { described_class.test_files_encrypted }

    context 'when ENV exists' do
      let(:test_files_encrypted) { 'true' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_FILES_ENCRYPTED' => test_files_encrypted }) }
      it { should eq test_files_encrypted }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_files_encrypted?' do
    subject { described_class.test_files_encrypted? }

    before do
      expect(described_class).to receive(:test_files_encrypted).and_return(test_files_encrypted)
    end

    context 'when enabled' do
      let(:test_files_encrypted) { 'true' }

      it { should be true }
    end

    context 'when disabled' do
      let(:test_files_encrypted) { nil }

      it { should be false }
    end
  end

  describe '.branch_encrypted' do
    subject { described_class.branch_encrypted }

    context 'when ENV exists' do
      let(:branch_encrypted) { 'true' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_BRANCH_ENCRYPTED' => branch_encrypted }) }
      it { should eq branch_encrypted }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.branch_encrypted?' do
    subject { described_class.branch_encrypted? }

    before do
      expect(described_class).to receive(:branch_encrypted).and_return(branch_encrypted)
    end

    context 'when enabled' do
      let(:branch_encrypted) { 'true' }

      it { should be true }
    end

    context 'when disabled' do
      let(:branch_encrypted) { nil }

      it { should be false }
    end
  end

  describe '.salt' do
    subject { described_class.salt }

    context 'when ENV exists' do
      let(:salt) { '123' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_SALT' => salt }) }
      it { should eq salt }
    end

    context "when ENV doesn't exist" do
      it do
        expect { subject }.to raise_error('Missing environment variable KNAPSACK_PRO_SALT')
      end
    end
  end

  describe '.endpoint' do
    subject { described_class.endpoint }

    context 'when ENV exists' do
      let(:endpoint) { 'http://api-custom-url.knapsackpro.com' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_ENDPOINT' => endpoint }) }
      it { should eq endpoint }
    end

    context "when ENV doesn't exist" do
      context 'when default mode' do
        it { should eq 'https://api.knapsackpro.com' }
      end

      context 'when development mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'development' }) }
        it { should eq 'http://api.knapsackpro.test:3000' }
      end

      context 'when test mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'test' }) }
        it { should eq 'https://api-staging.knapsackpro.com' }
      end

      context 'when production mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'production' }) }
        it { should eq 'https://api.knapsackpro.com' }
      end

      context 'when unknown mode' do
        before do
          expect(described_class).to receive(:mode).and_return(:fake)
        end

        it do
          expect { subject }.to raise_error('Missing environment variable KNAPSACK_PRO_ENDPOINT')
        end
      end
    end
  end

  describe '.fixed_test_suite_split?' do
    subject { described_class.fixed_test_suite_split? }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=true' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT' => 'true' }) }
        it { should be true }
      end

      context 'when KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT=false' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_FIXED_TEST_SUITE_SPLIT' => 'false' }) }
        it { should be false }
      end
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it { should be true }
    end
  end

  describe '.fixed_queue_split?' do
    subject { described_class.fixed_queue_split? }
    after(:each) { described_class.remove_instance_variable(:@fixed_queue_split) }

    context 'when ENV exists' do
      context 'when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=false' do
        [
          ['AppVeyor', { 'APPVEYOR' => '123' }],
          ['Buildkite', { 'BUILDKITE' => 'true' }],
          ['CircleCI', { 'CIRCLECI' => 'true' }],
          ['Cirrus CI', { 'CIRRUS_CI' => 'true' }],
          ['Codefresh', { 'CF_BUILD_ID' => '123' }],
          ['Codeship', { 'CI_NAME' => 'codeship' }],
          ['GitHub Actions', { 'GITHUB_ACTIONS' => 'true' }],
          ['GitLab CI', { 'GITLAB_CI' => 'true' }],
          ['Heroku CI', { 'HEROKU_TEST_RUN_ID' => '123' }],
          ['Semaphore CI 1.0', { 'SEMAPHORE_BUILD_NUMBER' => '123' }],
          ['Semaphore CI 2.0', { 'SEMAPHORE' => 'true', 'SEMAPHORE_WORKFLOW_ID' => '123' }],
          ['Travis CI', { 'TRAVIS' => 'true' }],
          ['Unsupported CI', {}],
        ].each do |ci, env|
          it "on #{ci} it is false" do
            stub_const("ENV", env.merge({ 'KNAPSACK_PRO_FIXED_QUEUE_SPLIT' => 'false' }))

            logger = instance_double(Logger)
            allow(KnapsackPro).to receive(:logger).and_return(logger)
            ci_env = described_class.detected_ci.new.fixed_queue_split
            if ci_env == false
              expect(logger).not_to receive(:info)
            else
              expect(logger).to receive(:info).with(
                'You have set the environment variable KNAPSACK_PRO_FIXED_QUEUE_SPLIT to false which could be automatically determined from the CI environment as true.'
              )
            end

            expect(subject).to eq(false)
          end
        end
      end

      context 'when KNAPSACK_PRO_FIXED_QUEUE_SPLIT=true' do
        [
          ['AppVeyor', { 'APPVEYOR' => '123' }],
          ['Buildkite', { 'BUILDKITE' => 'true' }],
          ['CircleCI', { 'CIRCLECI' => 'true' }],
          ['Cirrus CI', { 'CIRRUS_CI' => 'true' }],
          ['Codefresh', { 'CF_BUILD_ID' => '123' }],
          ['Codeship', { 'CI_NAME' => 'codeship' }],
          ['GitHub Actions', { 'GITHUB_ACTIONS' => 'true' }],
          ['GitLab CI', { 'GITLAB_CI' => 'true' }],
          ['Heroku CI', { 'HEROKU_TEST_RUN_ID' => '123' }],
          ['Semaphore CI 1.0', { 'SEMAPHORE_BUILD_NUMBER' => '123' }],
          ['Semaphore CI 2.0', { 'SEMAPHORE' => 'true', 'SEMAPHORE_WORKFLOW_ID' => '123' }],
          ['Travis CI', { 'TRAVIS' => 'true' }],
          ['Unsupported CI', {}],
        ].each do |ci, env|
          it "on #{ci} it is true" do
            stub_const("ENV", env.merge({ 'KNAPSACK_PRO_FIXED_QUEUE_SPLIT' => 'true' }))

            logger = instance_double(Logger)
            allow(KnapsackPro).to receive(:logger).and_return(logger)
            ci_env = described_class.detected_ci.new.fixed_queue_split
            if ci_env == true
              expect(logger).not_to receive(:info)
            else
              expect(logger).to receive(:info).with(
                'You have set the environment variable KNAPSACK_PRO_FIXED_QUEUE_SPLIT to true which could be automatically determined from the CI environment as false.'
              )
            end

            expect(subject).to eq(true)
          end
        end
      end
    end

    context "when ENV doesn't exist" do
      [
        ['AppVeyor', { 'APPVEYOR' => '123' }, false],
        ['Buildkite', { 'BUILDKITE' => 'true' }, true],
        ['CircleCI', { 'CIRCLECI' => 'true' }, false],
        ['Cirrus CI', { 'CIRRUS_CI' => 'true' }, false],
        ['Codefresh', { 'CF_BUILD_ID' => '123' }, false],
        ['Codeship', { 'CI_NAME' => 'codeship' }, true],
        ['GitHub Actions', { 'GITHUB_ACTIONS' => 'true' }, true],
        ['GitLab CI', { 'GITLAB_CI' => 'true' }, true],
        ['Heroku CI', { 'HEROKU_TEST_RUN_ID' => '123' }, false],
        ['Semaphore CI 1.0', { 'SEMAPHORE_BUILD_NUMBER' => '123' }, false],
        ['Semaphore CI 2.0', { 'SEMAPHORE' => 'true', 'SEMAPHORE_WORKFLOW_ID' => '123' }, false],
        ['Travis CI', { 'TRAVIS' => 'true' }, true],
        ['Unsupported CI', {}, true],
      ].each do |ci, env, expected|
        it "on #{ci} it is #{expected}" do
          stub_const("ENV", env)

          logger = instance_double(Logger)
          expect(KnapsackPro).to receive(:logger).and_return(logger)
          expect(logger).to receive(:info).with("KNAPSACK_PRO_FIXED_QUEUE_SPLIT is not set. Using default value: #{expected}. Learn more at #{KnapsackPro::Urls::FIXED_QUEUE_SPLIT}")

          expect(subject).to eq(expected)
        end
      end
    end
  end

  describe '.cucumber_queue_prefix' do
    subject { described_class.cucumber_queue_prefix }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_CUCUMBER_QUEUE_PREFIX' => 'bundle exec spring' }) }
      it { should eq 'bundle exec spring' }
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it { should eq 'bundle exec' }
    end
  end

  describe '.rspec_split_by_test_examples?' do
    subject { described_class.rspec_split_by_test_examples? }

    before do
      described_class.remove_instance_variable(:@rspec_split_by_test_examples) if described_class.instance_variable_defined?(:@rspec_split_by_test_examples)
    end
    after do
      described_class.remove_instance_variable(:@rspec_split_by_test_examples)
    end

    [
      ['false', '2', nil, false],
      ['true',  '2', nil, true],
      [nil,     '2', nil, true],
      ['false', '1', nil, false],
      ['true',  '1', nil, false, :debug, 'Skipping split by test examples because tests are running on a single CI node (no parallelism)'],
      [nil,     '1', nil, false, :debug, 'Skipping split by test examples because tests are running on a single CI node (no parallelism)'],
      ['false', '2', 'true', false],
      ['true',  '2', 'true', true],
      [nil,     '2', 'true', false, :warn, "Skipping split by test examples because test file names encryption is enabled:\nhttps://knapsackpro.com/perma/ruby/encryption\nhttps://knapsackpro.com/perma/ruby/split-by-test-examples"],
      ['false', '1', 'true', false],
      ['true',  '1', 'true', false, :debug, 'Skipping split by test examples because tests are running on a single CI node (no parallelism)'],
      [nil,     '1', 'true', false, :warn, "Skipping split by test examples because test file names encryption is enabled:\nhttps://knapsackpro.com/perma/ruby/encryption\nhttps://knapsackpro.com/perma/ruby/split-by-test-examples"],
    ].each do |sbte, node_total, encrypted, expected, log_level, log_message|
      context "KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES=#{sbte.inspect} AND KNAPSACK_PRO_CI_NODE_TOTAL=#{node_total.inspect} AND KNAPSACK_PRO_TEST_FILES_ENCRYPTED=#{encrypted.inspect}" do
        before do
          stub_const("ENV", { 'KNAPSACK_PRO_RSPEC_SPLIT_BY_TEST_EXAMPLES' => sbte, 'KNAPSACK_PRO_CI_NODE_TOTAL' => node_total, 'KNAPSACK_PRO_TEST_FILES_ENCRYPTED' => encrypted }.compact)

          if log_level && log_message
            logger = instance_double(Logger)
            expect(KnapsackPro).to receive(:logger).and_return(logger)
            expect(logger).to receive(log_level).once.with(log_message)
          end
        end

        it do
          expect(described_class.rspec_split_by_test_examples?).to eq(expected)
          expect(described_class.rspec_split_by_test_examples?).to eq(expected)
        end
      end
    end
  end

  describe '.rspec_test_example_detector_prefix' do
    subject { described_class.rspec_test_example_detector_prefix }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_RSPEC_TEST_EXAMPLE_DETECTOR_PREFIX' => '' }) }
      it { should eq '' }
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it { should eq 'bundle exec' }
    end
  end

  describe '.slow_test_file_threshold' do
    subject { described_class.slow_test_file_threshold }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_SLOW_TEST_FILE_THRESHOLD' => '2' }) }
      it 'returns seconds' do
        expect(subject).to eq 2.0
        expect(subject).to be_a Float
      end
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it { should be_nil }
    end
  end

  describe '.slow_test_file_threshold?' do
    subject { described_class.slow_test_file_threshold? }

    context 'when ENV exists' do
      before { stub_const("ENV", { 'KNAPSACK_PRO_SLOW_TEST_FILE_THRESHOLD' => '2' }) }
      it { should be true }
    end

    context "when ENV doesn't exist" do
      before { stub_const("ENV", {}) }
      it { should be false }
    end
  end

  describe '.test_suite_token' do
    subject { described_class.test_suite_token }

    context 'when ENV exists' do
      let(:token) { 'xyz' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN' => 'xyz' }) }
      it { should eq token }
    end

    context "when ENV doesn't exist" do
      it do
        expect { subject }.to raise_error('Missing environment variable KNAPSACK_PRO_TEST_SUITE_TOKEN. You should set environment variable like KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC (note there is suffix _RSPEC at the end). knapsack_pro gem will set KNAPSACK_PRO_TEST_SUITE_TOKEN based on KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC value. If you use other test runner than RSpec then use proper suffix.')
      end
    end
  end

  describe '.test_suite_token_rspec' do
    subject { described_class.test_suite_token_rspec }

    context 'when ENV exists' do
      let(:test_suite_token_rspec) { 'rspec-token' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_RSPEC' => test_suite_token_rspec }) }
      it { should eq test_suite_token_rspec }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_suite_token_minitest' do
    subject { described_class.test_suite_token_minitest }

    context 'when ENV exists' do
      let(:test_suite_token_minitest) { 'minitest-token' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_MINITEST' => test_suite_token_minitest }) }
      it { should eq test_suite_token_minitest }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_suite_token_test_unit' do
    subject { described_class.test_suite_token_test_unit }

    context 'when ENV exists' do
      let(:test_suite_token_test_unit) { 'test-unit-token' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_TEST_UNIT' => test_suite_token_test_unit }) }
      it { should eq test_suite_token_test_unit }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_suite_token_cucumber' do
    subject { described_class.test_suite_token_cucumber }

    context 'when ENV exists' do
      let(:test_suite_token_cucumber) { 'cucumber-token' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_CUCUMBER' => test_suite_token_cucumber }) }
      it { should eq test_suite_token_cucumber }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_suite_token_spinach' do
    subject { described_class.test_suite_token_spinach }

    context 'when ENV exists' do
      let(:test_suite_token_spinach) { 'spinach-token' }
      before { stub_const("ENV", { 'KNAPSACK_PRO_TEST_SUITE_TOKEN_SPINACH' => test_suite_token_spinach }) }
      it { should eq test_suite_token_spinach }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.mode' do
    subject { described_class.mode }

    context 'when ENV exists' do
      context 'when development mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'development' }) }

        it { should eq :development }
      end

      context 'when test mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'test' }) }

        it { should eq :test }
      end

      context 'when production mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'production' }) }

        it { should eq :production }
      end

      context 'when fake mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => 'fake' }) }

        it do
          expect { subject }.to raise_error(ArgumentError)
        end
      end

      context 'when blank mode' do
        before { stub_const("ENV", { 'KNAPSACK_PRO_MODE' => '' }) }

        it do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    context "when ENV doesn't exist" do
      it { should eq :production }
    end
  end

  describe '.log_level' do
    subject { described_class.log_level }

    context 'when ENV set to fatal' do
      let(:log_level) { 'fatal' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_LEVEL' => log_level }) }
      it { should eql ::Logger::FATAL }
    end

    context 'when ENV set to error' do
      let(:log_level) { 'error' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_LEVEL' => log_level }) }
      it { should eql ::Logger::ERROR }
    end

    context 'when ENV set to warn' do
      let(:log_level) { 'warn' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_LEVEL' => log_level }) }
      it { should eql ::Logger::WARN }
    end

    context 'when ENV set to info' do
      let(:log_level) { 'info' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_LEVEL' => log_level }) }
      it { should eql ::Logger::INFO }
    end

    context 'when ENV set with capital letters' do
      let(:log_level) { 'WARN' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_LEVEL' => log_level }) }
      it { should eql ::Logger::WARN }
    end

    context "when ENV doesn't exist" do
      it { should eql ::Logger::INFO }
    end
  end

  describe '.log_dir' do
    subject { described_class.log_dir }

    context 'when ENV set to directory path' do
      let(:log_dir) { 'log' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_LOG_DIR' => log_dir }) }
      it { should eql 'log' }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.test_runner_adapter' do
    subject { described_class.test_runner_adapter }

    context 'when ENV exists' do
      let(:test_runner_adapter) { 'RSpecAdapter' }
      before { stub_const('ENV', { 'KNAPSACK_PRO_TEST_RUNNER_ADAPTER' => test_runner_adapter }) }
      it { should eql 'RSpecAdapter' }
    end

    context "when ENV doesn't exist" do
      it { should be_nil }
    end
  end

  describe '.set_test_runner_adapter' do
    let(:adapter_class) { KnapsackPro::Adapters::RSpecAdapter }

    subject { described_class.set_test_runner_adapter(adapter_class) }

    it 'sets test runner adapter' do
      subject
      expect(described_class.test_runner_adapter).to eql 'RSpecAdapter'
    end
  end

  describe '.detected_ci' do
    [
      ['AppVeyor', { 'APPVEYOR' => '123' }, KnapsackPro::Config::CI::AppVeyor],
      ['Buildkite', { 'BUILDKITE' => 'true' }, KnapsackPro::Config::CI::Buildkite],
      ['CircleCI', { 'CIRCLECI' => 'true' }, KnapsackPro::Config::CI::Circle],
      ['Cirrus CI', { 'CIRRUS_CI' => 'true' }, KnapsackPro::Config::CI::CirrusCI],
      ['Codefresh', { 'CF_BUILD_ID' => '123' }, KnapsackPro::Config::CI::Codefresh],
      ['Codeship', { 'CI_NAME' => 'codeship' }, KnapsackPro::Config::CI::Codeship],
      ['GitHub Actions', { 'GITHUB_ACTIONS' => 'true' }, KnapsackPro::Config::CI::GithubActions],
      ['GitLab CI', { 'GITLAB_CI' => 'true' }, KnapsackPro::Config::CI::GitlabCI],
      ['Heroku CI', { 'HEROKU_TEST_RUN_ID' => '123' }, KnapsackPro::Config::CI::Heroku],
      ['Mint', { 'MINT' => 'true' }, KnapsackPro::Config::CI::Mint],
      ['Semaphore CI 1.0', { 'SEMAPHORE_BUILD_NUMBER' => '123' }, KnapsackPro::Config::CI::Semaphore],
      ['Semaphore CI 2.0', { 'SEMAPHORE' => 'true', 'SEMAPHORE_WORKFLOW_ID' => '123' }, KnapsackPro::Config::CI::Semaphore2],
      ['Travis CI', { 'TRAVIS' => 'true' }, KnapsackPro::Config::CI::Travis],
      ['Unsupported CI', {}, KnapsackPro::Config::CI::Base],
    ].each do |ci, env, expected|
      it "detects #{ci}" do
        stub_const("ENV", env)

        expect(described_class.detected_ci).to eq(expected)
      end
    end
  end

  describe '.ci?' do
    [
      ['CI from env', { 'CI' => 'True' }, true],
      ['Travis CI', { 'TRAVIS' => 'true' }, true],
      ['missing CI from ENV or development', {}, false],
    ].each do |ci, env, expected|
      it "detects #{ci}" do
        stub_const("ENV", env)

        expect(described_class.ci?).to eq(expected)
      end
    end
  end

  describe '.ci_provider' do
    [
      ['AppVeyor', { 'APPVEYOR' => '123' }],
      ['Azure Pipelines', { 'SYSTEM_TEAMFOUNDATIONCOLLECTIONURI' => '123' }],
      ['AWS CodeBuild', { 'CODEBUILD_BUILD_ARN' => '123' }],
      ['Bamboo', { 'bamboo_planKey' => '123' }],
      ['Bitbucket Pipelines', { 'BITBUCKET_COMMIT' => '123' }],
      ['Buddy.works', { 'BUDDY' => 'true' }],
      ['Buildkite', { 'BUILDKITE' => 'true' }],
      ['CircleCI', { 'CIRCLECI' => 'true' }],
      ['Cirrus CI', { 'CIRRUS_CI' => 'true' }],
      ['Codefresh', { 'CF_BUILD_ID' => '123' }],
      ['Codeship', { 'CI_NAME' => 'codeship' }],
      ['Drone.io', { 'DRONE' => 'true' }],
      ['GitHub Actions', { 'GITHUB_ACTIONS' => 'true' }],
      ['Gitlab CI', { 'GITLAB_CI' => 'true' }],
      ['Google Cloud Build', { 'BUILDER_OUTPUT' => '123' }],
      ['Heroku CI', { 'HEROKU_TEST_RUN_ID' => '123' }],
      ['Jenkins', { 'JENKINS_URL' => '123' }],
      ['Semaphore CI 1.0', { 'SEMAPHORE_BUILD_NUMBER' => '123' }],
      ['Semaphore CI 2.0', { 'SEMAPHORE' => 'true', 'SEMAPHORE_WORKFLOW_ID' => '123' }],
      ['TeamCity', { 'TEAMCITY_VERSION' => '123' }],
      ['Travis CI', { 'TRAVIS' => 'true' }],
      ['Other', { 'CI' => 'true'}],
      [nil, {}],
    ].each do |ci, env|
      it "detects #{ci || 'missing CI from env or development'}" do
        stub_const("ENV", env)

        expect(described_class.ci_provider).to eq(ci)
      end
    end
  end
end
