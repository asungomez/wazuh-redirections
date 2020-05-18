require 'rails_helper'

RSpec.feature "Refresh a branch", :type => :feature do
  scenario 'when the branch does not exist in the documentatiobn' do
    branch = FactoryBot.create(:branch, version: '0.4')
    visit branch_path(branch)
    click_on 'Refresh'
    expect(branch.pages.count).to eq(0)
    expect(page).to have_content 'This branch does not have any documentation pages'
  end
end