require 'rails_helper'

RSpec.feature "List branches", :type => :feature do
  scenario 'when there are no branches' do
    visit branches_path
    expect(page).to have_content 'There are no branches yet'
  end
end