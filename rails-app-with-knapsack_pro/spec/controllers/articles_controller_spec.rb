# Change :xfocus to :focus to test behaviour when
# config.filter_run_when_matching :focus is set in spec/spec_helper.rb
describe ArticlesController, :xfocus do
  describe '#index' do
    let(:articles) do
      [
        Article.create(title: 'Article 1'),
        Article.create(title: 'Article 2'),
      ]
    end

    before do
      expect(Article).to receive(:all).and_return(articles)

      get :index
    end

    it 'assigns the article' do
      expect(assigns(:articles)).to eq articles
    end

    it do
      expect(response).to be_successful
    end
  end

  describe '#show' do
    before do
      get :index
    end

    it do
      expect(response).to be_successful
    end
  end
end
