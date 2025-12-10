describe WelcomeController do
  describe '#index' do
    before do
      get :index
    end

    it do
      expect(response).to be_successful
    end
  end
end
