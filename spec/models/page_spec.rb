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

      it 'returns the destination with anchor if defined' do
        origin = FactoryBot.create(:page)
        destination_without_anchor = FactoryBot.create(:page)
        destination_with_anchor = FactoryBot.create(:page, branch: destination_without_anchor.branch)
        Redirection.create(from: origin.id, to: destination_without_anchor.id)
        Redirection.create(from: origin.id, to: destination_with_anchor.id, origin_anchor: 'something')

        expect(origin.destination_in(destination_with_anchor.branch, 'something')).to eq(destination_with_anchor)
      end

      it 'returns the default destination when no anchor is defined' do
        origin = FactoryBot.create(:page)
        destination_without_anchor = FactoryBot.create(:page)
        destination_with_anchor = FactoryBot.create(:page, branch: destination_without_anchor.branch)
        Redirection.create(from: origin.id, to: destination_without_anchor.id)
        Redirection.create(from: origin.id, to: destination_with_anchor.id, origin_anchor: 'something')

        expect(origin.destination_in(destination_without_anchor.branch)).to eq(destination_without_anchor)
      end

      it 'returns the default destination if the defined anchor does not have a specific one' do
        origin = FactoryBot.create(:page)
        destination = FactoryBot.create(:page)
        Redirection.create(from: origin.id, to: destination.id)
        expect(origin.destination_in(destination.branch, 'something')).to eq(destination)
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

      it 'creates a new renaming when current anchor is defined' do
        previous_without_anchor = FactoryBot.create(:page, branch: @previous_page.branch)
        previous_without_anchor.redirect_to(@current_page)
        @current_page.redirect_to(previous_without_anchor)

        @current_page.make_renamed(@previous_page, current_anchor: 'something')
        expect(@current_page.origins).to include(@previous_page)
        expect(@previous_page.destinations).to include(@current_page)
      end

      it 'does not delete previous renamings from the same branch with different current anchors' do
        previous_without_anchor = FactoryBot.create(:page, branch: @previous_page.branch)
        previous_without_anchor.redirect_to(@current_page)
        @current_page.redirect_to(previous_without_anchor)

        @current_page.make_renamed(@previous_page, current_anchor: 'something')
        expect(@current_page.origins).to include(previous_without_anchor)
        expect(previous_without_anchor.destinations).to include(@current_page)
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

      it 'returns only the origins without anchor if no anchor is defined' do
        FactoryBot.create_list(:branch, 2)
        current_branch = Branch.ordered.last
        previous_branch = current_branch.previous
        page = FactoryBot.create(:page, branch: current_branch)

        pointing_pages_without_anchor = FactoryBot.create_list(:page, 5, branch: previous_branch)
        pointing_pages_without_anchor.each do |pointing_page|
          pointing_page.redirect_to(page)
          page.redirect_to(pointing_page)
        end

        pointing_pages_with_anchor = FactoryBot.create_list(:page, 3, branch: previous_branch)
        pointing_pages_with_anchor.each do |pointing_page|
          pointing_page.redirect_to(page, destination_anchor: 'something')
          page.redirect_to(pointing_page, origin_anchor: 'something')
        end

        expect(page.origins_from(previous_branch).count).to eq(5)
      end

      it 'returns a different relation of origins if there is a destination anchor' do
        FactoryBot.create_list(:branch, 2)
        current_branch = Branch.ordered.last
        previous_branch = current_branch.previous
        page = FactoryBot.create(:page, branch: current_branch)

        pointing_pages_without_anchor = FactoryBot.create_list(:page, 5, branch: previous_branch)
        pointing_pages_without_anchor.each do |pointing_page|
          pointing_page.redirect_to(page)
          page.redirect_to(pointing_page)
        end

        pointing_pages_with_anchor = FactoryBot.create_list(:page, 3, branch: previous_branch)
        pointing_pages_with_anchor.each do |pointing_page|
          pointing_page.redirect_to(page, destination_anchor: 'something')
          page.redirect_to(pointing_page, origin_anchor: 'something')
        end

        expect(page.origins_from(previous_branch, 'something').count).to eq(3)
      end

      it 'returns a empty relation of origins for a destination anchor with no redirections' do
        FactoryBot.create_list(:branch, 2)
        current_branch = Branch.ordered.last
        previous_branch = current_branch.previous
        page = FactoryBot.create(:page, branch: current_branch)
        pointing_pages = FactoryBot.create_list(:page, 5, branch: previous_branch)
        pointing_pages.each do |pointing_page|
          pointing_page.redirect_to(page)
          page.redirect_to(pointing_page)
        end
        expect(page.origins_from(previous_branch, 'something')).to be_empty
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

      it 'creates a different redirection when origin anchor is defined' do
        origin = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        destination_without_anchor = FactoryBot.create(:page, branch: branch)
        origin.redirect_to(destination_without_anchor)
        destination_with_anchor = FactoryBot.create(:page, branch: branch)
        origin.redirect_to(destination_with_anchor, origin_anchor: 'something')
        expect(origin.destinations).to include(destination_with_anchor)
        expect(origin.redirections_to(branch).pluck(:origin_anchor)).to include('something')
      end

      it 'does not delete redirections to the same branch with different origin anchor' do
        origin = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        destination_without_anchor = FactoryBot.create(:page, branch: branch)
        origin.redirect_to(destination_without_anchor)
        destination_with_anchor = FactoryBot.create(:page, branch: branch)
        origin.redirect_to(destination_with_anchor, origin_anchor: 'something')
        expect(origin.destinations).to include(destination_without_anchor)
      end
    end

    describe '.redirections_from' do
      it 'returns an empty collection when there are no redirections from the branch' do
        page = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 3, branch: branch)
        origins_in_another_branches = FactoryBot.create_list(:page, 3)
        origins_in_another_branches.each do |origin|
          origin.redirect_to(page)
        end

        expect(page.redirections_from(branch)).to be_empty
      end

      it 'returns a list of redirections when there are redirections from the branch' do
        page = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        origins_in_branch = FactoryBot.create_list(:page, 3, branch: branch)
        origins_in_branch.each do |origin|
          FactoryBot.create(:redirection, from: origin.id, to: page.id)
        end

        expect(page.redirections_from(branch).count).to eq(origins_in_branch.count)
      end
    end

    describe '.redirections_to' do
      it 'returns an empty collection when there are no redirections to the branch' do
        page = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        FactoryBot.create_list(:page, 3, branch: branch)
        destinations_in_another_branches = FactoryBot.create_list(:page, 3)
        destinations_in_another_branches.each do |destination|
          page.redirect_to(destination)
        end

        expect(page.redirections_to(branch)).to be_empty
      end

      it 'returns a list of redirections when there are redirections to the branch' do
        page = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        destinations_in_branch = FactoryBot.create_list(:page, 3, branch: branch)
        destinations_in_branch.each do |destination|
          FactoryBot.create(:redirection, from: page.id, to: destination.id)
        end

        expect(page.redirections_to(branch).count).to eq(destinations_in_branch.count)
      end
    end

    describe '.type' do
      it 'returns deleted when it is a deleted page in that branch' do
        page = FactoryBot.create(:page)
        branch = FactoryBot.create(:branch)
        expect(page.type(branch)).to eq('deleted')
      end

      it 'returns new when it is a new page in that branch' do
        page = FactoryBot.create(:page)
        expect(page.type(page.branch)).to eq('new')
      end

      it 'returns renamed when it is a renamed page in that branch' do
        page = FactoryBot.create(:page, version: '1.1')
        page.make_renamed(FactoryBot.create(:page, version: '1.0'))
        expect(page.type(page.branch)).to eq('renamed')
      end

      it 'returns nil when none of the page types apply' do
        page = FactoryBot.create(:page, version: '1.1')
        previous_page = FactoryBot.create(:page, version: '1.0')
        page.make_renamed(previous_page)
        expect(previous_page.type(page.branch)).to be_nil
      end
    end
  end
end
