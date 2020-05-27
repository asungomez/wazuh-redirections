Given("A branch has some deleted pages") do
  @previous_branch = FactoryBot.create(:branch, version: '2.1')
  @branch = FactoryBot.create(:branch, version: '2.2')
  @deleted_pages = FactoryBot.create_list(:page, 5, branch: @previous_branch)
end

Given("A branch has some new pages") do
  @previous_branch = FactoryBot.create(:branch, version: '2.1')
  @branch = FactoryBot.create(:branch, version: '2.2')
  @new_pages = FactoryBot.create_list(:page, 5, branch: @branch)
end

Given("A branch has some renamed pages") do
  @previous_branch = FactoryBot.create(:branch, version: '2.1')
  @branch = FactoryBot.create(:branch, version: '2.2')
  @renamed_previous = FactoryBot.create_list(:page, 5, branch: @previous_branch)
  @renamed_current = FactoryBot.create_list(:page, 5, branch: @branch)

  5.times do |i|
    Redirection.create(from: @renamed_previous[i].id, to: @renamed_current[i].id)
  end
end

Given("The branch has a deleted page") do
  @deleted_page = FactoryBot.create(:page, branch: @previous_branch)
end

Given("The branch has a new page") do
  @previous_branch = FactoryBot.create(:branch, version: '2.1')
  @branch = FactoryBot.create(:branch, version: '2.2')
  @new_page = FactoryBot.create(:page, branch: @branch)
end


When("I mark the new page as renamed") do
  visit deleted_pages_branch_path(@branch)
  page.find('.list-group-item', text: @deleted_page.path).click_on 'Edit'
  select 'Renamed page', from: 'redirection_type'
  fill_in 'destination_page', with: @new_page.path
  page.find('.autocomplete .selected').click
  click_on 'Save'
end

When("I list the branch's deleted pages") do
  visit deleted_pages_branch_path(@branch)
end

When("I list the branch's new pages") do
  visit new_pages_branch_path(@branch)
end

When("I list the branch's renamed pages") do
  visit renamed_pages_branch_path(@branch)
end

When("I refresh a branch") do
  visit branch_path(@branch)
  click_on 'Refresh'
end


Then("I should not see the new page in the new pages list") do
  visit new_pages_branch_path(@branch)
  expect(page).not_to have_content(@new_page.path)
end

Then("I should not see the older page in the deleted pages list") do
  visit deleted_pages_branch_path(@branch)
  expect(page).not_to have_content(@deleted_page.path)
end

Then("I should see all of the branch's deleted pages") do
  @deleted_pages.each do |deleted_page|
    expect(page).to have_content(deleted_page.path)
  end
end

Then("I should see all of the branch's new pages") do
  @new_pages.each do |new_page|
    expect(page).to have_content(new_page.path)
  end
end

Then("I should see all of the branch's renamed pages") do
  @renamed_current.each do |new_page|
    expect(page).to have_content(new_page.path)
  end
end

Then("I should see an updated list of its pages") do
  expect(@branch.pages.count).to be > 0
end

Then("I should see the page in the renamed pages list") do
  visit renamed_pages_branch_path(@branch)
  expect(page).to have_content(@new_page.path)
end
