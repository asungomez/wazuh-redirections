require 'rails_helper'

RSpec.feature "List branch's deleted pages", :type => :feature do
  scenario 'when the branch has not deleted pages' do
    branch = FactoryBot.create(:branch, version: '0.4')
    visit deleted_pages_branch_path(branch)
    expect(page).to have_content 'This branch does not have any deleted pages'
  end
end