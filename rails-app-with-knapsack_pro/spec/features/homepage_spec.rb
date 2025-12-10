describe 'Homepage Features' do
  before do
    visit root_path
  end

  it 'has welcome text' do
    expect(page).to have_content 'Welcome'
  end

  it 'has link to calculator page' do
    click_link 'Calculator'
    expect(current_path).to eq calculator_index_path
  end
end
