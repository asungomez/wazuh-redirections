require 'rails_helper'

RSpec.feature "List branches", :type => :feature do
  scenario 'when the version is left blank' do
    visit new_branch_path
    click_on 'Save'
    expect(page).to have_content "Version can't be blank"
  end
end