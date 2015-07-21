describe KnapsackPro::Credentials do
  let(:empty_credentials) do
    {
      endpoint: nil,
      username: nil,
      password: nil,
    }
  end
  let(:custom_credentials) do
    {
      endpoint: 'endpoint',
      username: 'username',
      password: 'password',
    }
  end
  let(:env_credentials) do
    {
      endpoint: 'endpoint2',
      username: 'username2',
      password: 'password2',
    }
  end
  let(:envs) do
    {
      'KNAPSACK_PRO_ENDPOINT' => 'endpoint2',
      'KNAPSACK_PRO_USERNAME' => 'username2',
      'KNAPSACK_PRO_PASSWORD' => 'password2',
    }
  end

  let(:credentials) { described_class.new(:endpoint, :username, :password) }

  describe '#get' do
    subject { credentials.get }

    context 'when defined custom credentials' do
      before { credentials.set = custom_credentials }

      it { should eq custom_credentials }
    end

    context 'when defined ENV credentials' do
      before do
        stub_const('ENV', envs)
      end

      it { should eq env_credentials }
    end

    context 'when not defined custom credentials & not defined ENV credentials' do
      before do
        stub_const('ENV', {})
      end

      it do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'when defined custom credentials & defined ENV credentials' do
      before do
        credentials.set = custom_credentials
        stub_const('ENV', envs)
      end

      it 'custom credentials have higher priority than ENV credentials' do
        should eq custom_credentials
      end

      context 'when set_default' do
        before do
          credentials.set_default
        end

        it { should eq env_credentials }
      end
    end
  end

  describe '#set' do
    subject { credentials.set = custom_credentials }

    context 'when custom credentials have valid keys' do
      it do
        subject
        expect(credentials.get). to eq custom_credentials
      end
    end

    context 'when custom credentials have invalid keys' do
      let(:custom_credentials) do
        { fake_key: 'value' }
      end

      it do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end
end
