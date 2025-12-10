describe 'Bar', :tag_a do
  it 'Bar 1' do
    expect(Article.new).to be_kind_of Article
  end

  it 'Bar 2 - tag_x', :tag_x do
  end

  it 'Bar 3 - tag_x', :tag_x do
  end

  it 'Bar 4 - tag_x AND tag_y', :tag_x, :tag_y do

  end

  it 'Bar 5 - I might fail', :skip_me_or_i_will_fail do
    if ENV['SKIP_ME_OR_I_WILL_FAIL'] == 'true'
      raise 'You should skip this test by passing --tag ~@skip_me_or_i_will_fail to Knapsack Pro'
    end
  end
end
