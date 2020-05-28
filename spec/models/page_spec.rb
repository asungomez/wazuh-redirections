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

  describe 'Methods' do
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

    describe '.is_deleted?' do
      it 'returns false when the page belongs to the last branch' do
        expect(FactoryBot.create(:page).is_deleted?).to be false
      end

      it 'returns true when the page has no redirections to or from the next branch' do
        FactoryBot.create(:branch, version: '1.1')
        expect(FactoryBot.create(:page, version: '1.0').is_deleted?).to be true
      end

      it 'returns false when the page is renamed in the next branch' do
        next_page = FactoryBot.create(:page, version: '1.1')
        page = FactoryBot.create(:page, version: '1.0')
        next_page.make_renamed(page)
        expect(page.is_deleted?).to be false
      end
    end

    describe '.is_new?' do
      it 'returns true when the page belongs to the first branch' do
        expect(FactoryBot.create(:page).is_new?).to be true
      end

      it 'returns true when the page has no redirections to or from the previous branch' do
        FactoryBot.create(:branch, version: '1.0')
        expect(FactoryBot.create(:page, version: '1.1').is_new?).to be true
      end

      it 'returns false when the page is renamed' do
        page = FactoryBot.create(:page, version: '1.1')
        page.make_renamed(FactoryBot.create(:page, version: '1.0'))
        expect(page.is_new?).to be false
      end
    end

    describe '.is_renamed?' do
      it 'returns false when the page belongs to the first branch' do
        expect(FactoryBot.create(:page).is_renamed?).to be false
      end

      it 'returns true when the page has one bidirectional redirection from the previous branch' do
        page = FactoryBot.create(:page, version: '1.1')
        page.make_renamed(FactoryBot.create(:page, version: '1.0'))
        expect(page.is_renamed?).to be true
      end

      it 'returns false when the page is new' do
        expect(FactoryBot.create(:page).is_renamed?).to be false
      end
    end

    describe '.make_new' do
      it 'does nothing when the page is already new' do
        page = FactoryBot.create(:page)
        expect{
          page.make_new
        }.not_to change(Redirection, :count)
      end
  
      it 'deletes all redirections from the previous branch pointing to the page' do
        page = FactoryBot.create(:page, version: '1.2')
        previous_pages = FactoryBot.create_list(:page, 5, version: '1.1')
        previous_pages.each do |previous_page|
          previous_page.redirect_to(page)
        end
  
        expect{
          page.make_new
        }.to change(Redirection, :count).by(-5)
      end
    end

    describe '.make_renamed' do
      before(:each) do
        @previous_page = FactoryBot.create(:page, version: '1.1')
        @current_page = FactoryBot.create(:page, version: '1.2')
      end
  
      it 'does nothing when passing a nil page' do
        expect{
          @current_page.make_renamed(nil)
        }.not_to change(Redirection, :count)
      end
  
      it 'creates a bidirectional redirection when passing a valid page' do
        @current_page.make_renamed(@previous_page)
        expect(@current_page.origins).to include(@previous_page)
        expect(@previous_page.destinations).to include(@current_page)
      end
  
      it 'deletes all redirections from the origin branch to the destination page' do
        origin_to_be_deleted = FactoryBot.create(:page, version: '1.1')
        origin_to_be_deleted.redirect_to(@current_page)
        @current_page.make_renamed(@previous_page)
        expect(origin_to_be_deleted.destinations).not_to include(@current_page)
      end
  
      it 'deletes all redirections from the destination branch to the origin page' do
        destination_to_be_deleted = FactoryBot.create(:page, version: '1.2')
        @previous_page.redirect_to(destination_to_be_deleted)
        @current_page.make_renamed(@previous_page)
        expect(destination_to_be_deleted.origins).not_to include(@previous_page)
      end
    end

    describe '.origins_from' do
      it 'returns an empty relation when there are no origins' do
        FactoryBot.create_list(:branch, 2)
        page = FactoryBot.create(:page)
        expect(page.origins_from(Branch.where.not(id: page.branch.id).first)).to be_empty
      end
  
      it 'returns a relation of origins from this branch' do
        FactoryBot.create_list(:branch, 2)
        current_branch = Branch.ordered.last
        previous_branch = current_branch.previous
        page = FactoryBot.create(:page, branch: current_branch)
        pointing_pages = FactoryBot.create_list(:page, 5, branch: previous_branch)
        pointing_pages.each do |pointing_page|
          pointing_page.redirect_to(page)
          page.redirect_to(pointing_page)
        end
        expect(page.origins_from(previous_branch).count).to eq(5)
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
  end
end
