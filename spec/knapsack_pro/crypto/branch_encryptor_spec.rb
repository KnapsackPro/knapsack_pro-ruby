describe KnapsackPro::Crypto::BranchEncryptor do
  subject { described_class.call(branch) }

  context 'with branch encryption and branch present' do
    let(:branch) { 'feature-branch' }

    before do
      allow(KnapsackPro::Config::Env).to receive(:branch_encrypted?).and_return(true)
      allow(KnapsackPro::Config::Env).to receive(:salt).and_return("123")
    end

    it { should eq "49e5bb1" }
  end

  context 'with branch encryption and branch nil' do
    let(:branch) { nil }

    before do
      allow(KnapsackPro::Config::Env).to receive(:branch_encrypted?).and_return(true)
    end

    it { should be_nil }
  end

  context 'without branch encryption and branch present' do
    let(:branch) { 'feature-branch' }

    before do
      allow(KnapsackPro::Config::Env).to receive(:branch_encrypted?).and_return(false)
    end

    it { should eq branch }
  end

  context 'without branch encryption and branch nil' do
    let(:branch) { nil }

    before do
      allow(KnapsackPro::Config::Env).to receive(:branch_encrypted?).and_return(false)
    end

    it { should be_nil }
  end

  described_class::NON_ENCRYPTABLE_BRANCHES.each do |branch_name|
    context "with non-encryptable branch name: #{branch_name}" do
      let(:branch) { branch_name }

      it { should eq branch_name }
    end
  end
end
