require 'rails_helper'

RSpec.describe Page, type: :model do


  describe 'Scopes' do
    describe '.added' do
      it 'returns an empty list when no pages were added' do
        from = FactoryBot.create(:branch)
        to = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 10, branch: from)
        expect(Page.added(from, to).count).to eq(0)
      end

      it 'returns a non empty list when some pages were added' do
        from = FactoryBot.create(:branch)
        to = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 10, branch: to)
        expect(Page.added(from, to).count).to eq(10)
      end
    end

    describe '.removed' do
      it 'returns an empty list when no pages were removed' do
        from = FactoryBot.create(:branch)
        to = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 10, branch: to)
        expect(Page.removed(from, to).count).to eq(0)
      end

      it 'returns a non empty list when some pages were removed' do
        from = FactoryBot.create(:branch)
        to = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 10, branch: from)
        expect(Page.removed(from, to).count).to eq(10)
      end
    end
  end


  describe '.redirect_to' do
    it 'creates a redirection between two pages' do
      origin = FactoryBot.create(:page)
      destination = FactoryBot.create(:page)
      origin.redirect_to(destination)
      expect(origin.destinations).to include(destination)
    end

    it 'deletes the previous redirection for this origin to the destination branch' do
      origin = FactoryBot.create(:page)
      old_destination = FactoryBot.create(:page)
      Redirection.create(from: origin.id, to: old_destination.id)
      new_destination = FactoryBot.create(:page, branch: old_destination.branch)
      origin.redirect_to(new_destination)
      expect(origin.destinations).to include(new_destination)
      expect(origin.destinations).not_to include(old_destination)
    end
  end

  describe '.destination_in' do
    it 'returns the destination page if there is a redirection' do
      origin = FactoryBot.create(:page)
      destination = FactoryBot.create(:page)
      Redirection.create(from: origin.id, to: destination.id)
      expect(origin.destination_in(destination.branch)).to eq(destination)
    end

    it 'returns nil if there is not a redirection' do
      origin = FactoryBot.create(:page)
      destination = FactoryBot.create(:page)
      expect(origin.destination_in(destination.branch)).to be_nil
    end
  end
end
