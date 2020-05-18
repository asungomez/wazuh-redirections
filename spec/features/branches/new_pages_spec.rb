require 'rails_helper'

RSpec.feature "List branch's new pages", :type => :feature do
  scenario 'when the branch not new pages' do
    branch = FactoryBot.create(:branch, version: '0.4')
    visit new_pages_branch_path(branch)
    expect(page).to have_content 'This branch does not have any new pages'
  end
end