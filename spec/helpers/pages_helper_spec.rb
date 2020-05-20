require 'rails_helper'

RSpec.describe PagesHelper, type: :helper do
  describe '.redirection_types' do
    it 'returns the Deleted page option when using a deleted page' do
      expect(helper.redirection_types(deleted_page: true)).to include(['Deleted page', 'deleted_page_form'])
    end

    it 'does not return the New page option when using a deleted page' do
      expect(helper.redirection_types(deleted_page: true)).not_to include(['New page', 'new_page_form'])
    end

    it 'returns the New page option when using a new page' do
      expect(helper.redirection_types(deleted_page: false)).to include(['New page', 'new_page_form'])
    end

    it 'does not return the Deleted page option when using a new page' do
      expect(helper.redirection_types(deleted_page: false)).not_to include(['Deleted page', 'deleted_page_form'])
    end
  end

  describe '.rename_form_params' do
    it 'sets the page as destination when it belongs to the branch' do
      branch = FactoryBot.create(:branch)
      page = FactoryBot.create(:page, branch: branch)
      expect(helper.rename_form_params(branch, page)[:destination]).to eq(page)
    end

    it 'sets the page as origin when it does not belong to the branch' do
      branch = FactoryBot.create(:branch)
      page = FactoryBot.create(:page)
      expect(helper.rename_form_params(branch, page)[:origin]).to eq(page)
    end
  end

  describe '.origins_for_autocomplete' do
  end

  describe '.destinations_for_autocomplete' do
  end
end
