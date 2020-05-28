require 'rails_helper'

RSpec.describe PagesHelper, type: :helper do
  describe '.redirection_options_for_select' do

    before(:each) do
      @select_options = {
        deleted: ['Deleted page', 'deleted_page_form'],
        new: ['New page', 'new_page_form'],
        renamed: ['Renamed page', 'renamed_page_form']
      }
    end

    it 'returns the Deleted page option when passing a page from the previous branch' do
      page = FactoryBot.create(:page, version: '1.0')
      branch = FactoryBot.create(:branch, version: '1.1')
      expect(helper.redirection_options_for_select(page, branch)).to include @select_options[:deleted]
    end

    it 'does not return the Deleted page option when passing a page from the same branch' do
      page = FactoryBot.create(:page)
      expect(helper.redirection_options_for_select(page, page.branch)).not_to include @select_options[:deleted]
    end

    it 'returns the New page option when passing a page from the same branch' do
      page = FactoryBot.create(:page)
      expect(helper.redirection_options_for_select(page, page.branch)).to include @select_options[:new]
    end

    it 'does not return the New page option when passing a page from a different branch' do
      page = FactoryBot.create(:page, version: '1.0')
      branch = FactoryBot.create(:branch, version: '1.1')
      expect(helper.redirection_options_for_select(page, branch)).not_to include @select_options[:new]
    end
  end

  describe '.rename_form_params' do
    it 'sets the page as destination when it belongs to the branch' do
      page = FactoryBot.create(:page)
      expect(helper.rename_form_params(page.branch, page)[:destination]).to eq(page)
    end

    it 'sets the page as origin when it does not belong to the branch' do
      page = FactoryBot.create(:page)
      expect(helper.rename_form_params(FactoryBot.create(:branch), page)[:origin]).to eq(page)
    end
  end

  describe '.origins_for_autocomplete' do
  end

  describe '.destinations_for_autocomplete' do
  end
end
