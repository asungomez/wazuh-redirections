require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let(:invalid_branch_id) do
    Branch.count + 1
  end

  let(:invalid_page_id) do
    Page.count + 1
  end

  describe 'GET #edit_redirection' do
    context 'when it is a new page' do
      it 'returns a success response' do
        FactoryBot.create_list(:branch, 2)
        branch = Branch.ordered.last
        page = FactoryBot.create(:page, branch: branch)
        get :edit_redirection, params: {branch_id: branch.id, page_id: page.id}
        expect(response).to be_successful
      end
    end

    context 'when it is a deleted page' do
      it 'returns a success response' do
        FactoryBot.create_list(:branch, 2)
        branch = Branch.ordered.last
        page = FactoryBot.create(:page, branch: Branch.ordered.first)
        get :edit_redirection, params: {branch_id: branch.id, page_id: page.id}
        expect(response).to be_successful
      end
    end

    context 'when it is a renamed page' do
      it 'returns a success response' do
        FactoryBot.create_list(:branch, 2)
        branch = Branch.ordered.last
        previous_branch = Branch.ordered.first
        deleted_page = FactoryBot.create(:page, branch: previous_branch)
        new_page = FactoryBot.create(:page, branch: branch)
        deleted_page.redirect_to(new_page)
        get :edit_redirection, params: {branch_id: branch.id, page_id: new_page.id}
        expect(response).to be_successful
      end
    end

    context 'when the page does not exist but the branch does' do
      it 'redirects to the branch page' do
        branch = FactoryBot.create(:branch)
        get :edit_redirection, params: {branch_id: branch.id, page_id: invalid_page_id }
        expect(response).to redirect_to(branch_path(branch))
      end
    end

    context 'when the branch does not exist' do
      it 'redirects to the branches page' do
        page = FactoryBot.create(:page)
        get :edit_redirection, params: {branch_id: invalid_branch_id, page_id: page.id}
        expect(response).to redirect_to(branches_path)
      end
    end
  end

  describe 'POST #rename_page' do
    context 'when parameters are correct' do
      before(:each) do
        FactoryBot.create_list(:branch, 2)
        @previous_branch = Branch.ordered.first
        @current_branch = Branch.ordered.last 
        @origin = FactoryBot.create(:page, branch: @previous_branch)
        @destination = FactoryBot.create(:page, branch: @current_branch)
      end

      context 'and none of them had conflicting redirections' do
        it 'redirects to the branch renamed pages' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id}
          expect(response).to redirect_to renamed_pages_branch_path(@current_branch)
        end

        it 'creates a bidirectional redirection' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(@origin.destinations).to include(@destination)
          expect(@destination.destinations).to include(@origin)
        end
      end

      context 'and the origin had a conflicting redirection' do
        before(:each) do
          @conflicting_destination = FactoryBot.create(:page, branch: @current_branch)
          @origin.redirect_to(@conflicting_destination)
        end

        it 'redirects to the branch renamed pages' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(response).to redirect_to renamed_pages_branch_path(@current_branch)
        end

        it 'creates a bidirectional redirection' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(@origin.destinations).to include(@destination)
          expect(@destination.destinations).to include(@origin)
        end

        it 'deletes the conflicting redirection' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(@origin.destinations).not_to include(@conflicting_destination)
        end
      end

      context 'and the destination had a confliction redirection' do
        before(:each) do
          @conflicting_origin = FactoryBot.create(:page, branch: @previous_branch)
          @destination.redirect_to(@conflicting_origin)
        end

        it 'redirects to the branch renamed pages' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(response).to redirect_to renamed_pages_branch_path(@current_branch)
        end

        it 'creates a bidirectional redirection' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(@origin.destinations).to include(@destination)
          expect(@destination.destinations).to include(@origin)
        end

        it 'deletes the conflicting redirection' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: @destination.id }
          expect(@destination.destinations).not_to include(@conflicting_origin)
        end
      end
    end

    context 'when parameters are invalid' do
      context 'because origin does not exist' do
        before(:each) do
          @destination = FactoryBot.create(:page)
        end

        it 'redirects to the branches page' do
          post :rename_page, params: {origin_id: invalid_page_id, destination_id: @destination.id }
          expect(response).to redirect_to(branches_path)
        end

        it 'does not create any redirections' do
          expect {
            post :rename_page, params: {origin_id: invalid_page_id, destination_id: @destination.id }
          }.not_to change{Redirection.count}
        end

        it 'does not delete any of the destination page redirections' do
          expect {
            post :rename_page, params: {origin_id: invalid_page_id, destination_id: @destination.id }
          }.not_to change{@destination.origin_redirections}
        end
      end

      context 'because destination does not exist' do
        before(:each) do
          @origin = FactoryBot.create(:page)
        end

        it 'redirects to the branches page' do
          post :rename_page, params: {origin_id: @origin.id, destination_id: invalid_page_id }
          expect(response).to redirect_to(branches_path)
        end

        it 'does not create any redirections' do
          expect {
            post :rename_page, params: {origin_id: @origin.id, destination_id: invalid_page_id }
          }.not_to change{Redirection.count}
        end

        it 'does not delete any of the origin page redirections' do
          expect {
            post :rename_page, params: {origin_id: @origin.id, destination_id: invalid_page_id }
          }.not_to change{@origin.destination_redirections}
        end
      end
    end
  end

  describe 'POST #mark_as_new' do
    context 'when parameters are correct' do
      context 'and the page is already new' do
        before(:each) do
          @page = FactoryBot.create(:page)
        end

        it 'redirects to the branch new pages' do
          post :mark_as_new, params: {page_id: @page.id}
          expect(response).to redirect_to new_pages_branch_path(@page.branch)
        end

        it 'does not change the redirections' do
          expect{
            post :mark_as_new, params: {page_id: @page.id}
          }.not_to change(Redirection, :count)
        end
      end

      context 'and the page is renamed' do
        before(:each) do
          previous_page = FactoryBot.create(:page, version: '1.0')
          @page = FactoryBot.create(:page, version: '1.1')
          previous_page.redirect_to(@page)
        end

        it 'redirects to the branch new pages' do
          post :mark_as_new, params: {page_id: @page.id}
          expect(response).to redirect_to new_pages_branch_path(@page.branch)
        end

        it 'deletes the renaming redirection' do
          expect{
            post :mark_as_new, params: {page_id: @page.id}
          }.to change(Redirection, :count).by(-1)
        end
      end
    end

    context 'when parameters are invalid' do
      context 'because the page does not exist' do
        it 'redirects to the branches page' do
          post :mark_as_new, params: {page_id: invalid_page_id}
          expect(response).to redirect_to branches_path
        end

        it 'does not change the redirections' do
          expect{
            post :mark_as_new, params: {page_id: invalid_page_id}
          }.not_to change(Redirection, :count)
        end
      end
    end
  end
end