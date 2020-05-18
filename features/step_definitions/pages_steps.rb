When("I refresh a branch") do
  visit branch_path(@branch)
  click_on 'Refresh'
end

Then("I should see an updated list of its pages") do
  expect(@branch.pages.count).to be > 0
end
