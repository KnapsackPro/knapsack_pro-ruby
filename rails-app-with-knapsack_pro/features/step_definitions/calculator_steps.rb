Given /^I visit calculator$/ do
  visit calculator_index_path
end

When /^there are ([0-9]+) cucumbers$/ do |cucumbers|
  fill_in 'calculator[x]', with: cucumbers
end

When /^I add ([0-9]+) cucumbers$/ do |cucumbers|
  fill_in 'calculator[y]', with: cucumbers
  click_button 'Add'
end

Then /^I should have ([0-9]+) cucumbers$/ do |cucumbers|
  expect(page).to have_content "Result is #{cucumbers}"
end
