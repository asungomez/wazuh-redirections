require 'rails_helper'

RSpec.feature "List branch's renamed pages", :type => :feature do
  scenario 'when the branch not renamed pages' do
    branch = FactoryBot.create(:branch, version: '0.4')
    visit renamed_pages_branch_path(branch)
    expect(page).to have_content 'This branch does not have any renamed pages'
  end
end