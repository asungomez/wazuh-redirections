Given("A branch has some new pages") do
  @previous_branch = FactoryBot.create(:branch, version: '2.1')
  @branch = FactoryBot.create(:branch, version: '2.2')
  @new_pages = FactoryBot.create_list(:page, 5, branch: @branch)
end

When("I refresh a branch") do
  visit branch_path(@branch)
  click_on 'Refresh'
end

Then("I should see an updated list of its pages") do
  expect(@branch.pages.count).to be > 0
end

When("I list the branch's new pages") do
  visit new_pages_branch_path(@branch)
end

Then("I should see all of the branch's new pages") do
  @new_pages.each do |new_page|
    expect(page).to have_content(new_page.path)
  end
end
