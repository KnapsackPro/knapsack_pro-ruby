describe_shared_specs_for(:articles_controller) do
  describe ArticlesController do
    describe 'root tests in articles controller' do
      run_shared_specs!
    end
  end
end

described_nested_shared_specs_for(:articles_controller, :index) do
  describe "#index" do
    subject { get :index }

    context "when found articles" do
      let(:articles) do
        [
          Article.create(title: 'Article 1'),
          Article.create(title: 'Article 2'),
        ]
      end

      before do
        expect(Article).to receive(:all).and_return(articles)
      end

      run_shared_specs!
    end
  end
end
