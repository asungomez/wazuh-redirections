require 'rails_helper'

RSpec.feature "List branch's renamed pages", :type => :feature do
  describe 'editing a deleted page' do
    before(:each) do
      FactoryBot.create_list(:branch, 2)
      @previous_branch = Branch.ordered.first
      @current_branch = Branch.ordered.last
      @deleted_page = FactoryBot.create(:page, branch: @previous_branch)
      FactoryBot.create_list(:page, 5, branch: @current_branch)
      visit edit_redirection_path(@current_branch,@deleted_page)
    end

    scenario 'it displays an error when there are no new pages' do
      @current_branch.pages.destroy_all
      visit edit_redirection_path(@current_branch,@deleted_page)
      select 'Renamed page', from: 'redirection_type'
      expect(page).to have_content 'There are no destination URLs available'
    end

    scenario 'it does not let you select the New Page option' do
      expect(page).not_to have_css('select#redirection-selector option[value="new_page_form"]')
    end

    scenario 'it disables the origin page selector' do
      expect(page.find('#origin_page')).to be_disabled
    end

    scenario 'it autocompletes the origin page selector' do
      expect(page.find('#origin_page').value).to eq(@deleted_page.path)
    end

    scenario 'it displays an error message when the destination page does not exist' do
      fill_in 'destination_page', with: '@@@@'
      click_on 'Save'
      expect(page).to have_content 'The specified path does not exist'
    end
  end

  describe 'editing a new page' do
    before(:each) do
      FactoryBot.create_list(:branch, 2)
      @previous_branch = Branch.ordered.first
      @current_branch = Branch.ordered.last
      @new_page = FactoryBot.create(:page, branch: @current_branch)
      FactoryBot.create_list(:page, 5, branch: @previous_branch)
      visit edit_redirection_path(@current_branch,@new_page)
    end

    scenario 'it displays an error when there are no deleted pages' do
      @previous_branch.pages.destroy_all
      visit edit_redirection_path(@current_branch,@new_page)
      select 'Renamed page', from: 'redirection_type'
      expect(page).to have_content 'There are no origin URLs available'
    end

    scenario 'it does not let you select the Deleted Page option' do
      expect(page).not_to have_css('select#redirection-selector option[value="delete_page_form"]')
    end

    scenario 'it disables the destination page selector' do
      expect(page.find('#destination_page')).to be_disabled
    end

    scenario 'it autocompletes the destination page selector' do
      expect(page.find('#destination_page').value).to eq(@new_page.path)
    end

    scenario 'it displays an error message when the origin page does not exist' do
      fill_in 'origin_page', with: '@@@@'
      click_on 'Save'
      expect(page).to have_content 'The specified path does not exist'
    end
  end
end