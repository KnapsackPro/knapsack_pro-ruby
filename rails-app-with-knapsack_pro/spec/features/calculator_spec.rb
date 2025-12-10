describe 'Calculator Page', :tag_a do
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

    # This test is only to test whether the capybara-screenshot can do screenshot when test fails and we run knapsack_pro in Queue Mode.
    # To test it the test should fail. Remove x before it.
    # Sometimes this couldn't be reproduced.
    #
    # Here is other example of repo that reproduced the error:
    # https://gist.github.com/toolmantim/2a1d73fd2f8cca15f38255995af035a2
    #
    # Fix is here: https://github.com/mattheworiordan/capybara-screenshot/pull/205
    # We use forked capybara-screenshot gem in Gemfile
    xit 'this must fail' do
      fill_in 'calculator_x', with: '2'
      fill_in 'calculator_y', with: '3'
      click_button 'Add'
      expect(page).to have_content 'Result is fake'
    end
  end
end
