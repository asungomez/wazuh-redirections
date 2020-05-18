Given("I have some branches") do
  FactoryBot.create_list(:branch, 5)
  @branch = Branch.first
end

When("I create a new branch") do
  @branch = FactoryBot.build(:branch)
  visit new_branch_path
  fill_in 'branch_version', with: @branch.version
  click_on 'Save'
end

When("I delete a branch") do
  visit branches_path
  page.find('.list-group-item', text: @branch.version).click_on('Delete')
end

When("I rename a branch") do
  @new_branch = FactoryBot.build(:branch)
  visit edit_branch_path(@branch)
  fill_in 'branch_version', with: @new_branch.version 
  click_on 'Save'
end

When("I visit a branch details page") do
  pending # Write code here that turns the phrase above into concrete actions
end

When("I visit the branches index page") do
  visit branches_path
end

Then("I should not see the deleted branch in the branches list") do
  visit branches_path 
  expect(page).not_to have_content @branch.version
end

Then("I should not see the old branch name in the branches list") do
  visit branches_path
  expect(page).not_to have_content @branch.version
end

Then("I should see all branches listed") do
  Branch.all.each do |branch|
    expect(page).to have_content branch.version
  end
end

Then("I should see a list of its pages") do
  pending # Write code here that turns the phrase above into concrete actions
end

Then("I should see the new branch in the branches list") do
  visit branches_path 
  expect(page).to have_content @branch.version
end

Then("I should see the new branch name in the branches list") do
  visit branches_path
  expect(page).to have_content @new_branch.version
end
