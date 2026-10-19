describe 'Calculator Page' do
  before do
    visit calculator_index_path
  end

  context 'when try to add without provided numbers' do
    it 'result is 0' do
      click_button 'Add'
      expect(page).to have_content 'Result is 0'
    end
  end

  context 'when add two numbers' do
    it 'result is 0' do
      fill_in 'calculator_x', with: '2'
      fill_in 'calculator_y', with: '3'
      click_button 'Add'
      expect(page).to have_content 'Result is 5'
    end
  end
end
