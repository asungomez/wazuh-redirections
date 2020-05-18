require 'rails_helper'

RSpec.describe BranchesController, type: :controller do

  let(:invalid_id) do
    Branch.count + 1
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    before(:each) do
      @branch = FactoryBot.create(:branch)
    end

    context 'when the branch exists' do
      it 'returns a success response' do
        get :edit, params: { id: @branch.id }
        expect(response).to be_successful
      end
    end

    context 'when the branch does not exist' do
      it 'redirects to branches page' do
        get :edit, params: { id: invalid_id }
        expect(response).to redirect_to branches_path
      end
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do 
      before(:each) do
        @new_branch = FactoryBot.attributes_for(:branch)
      end

      it 'redirects to the show page' do 
        post :create, params: { branch: @new_branch }
        expect(response).to redirect_to branch_path(Branch.last)
      end

      it 'creates a new branch' do 
        expect{
          post :create, params: { branch: @new_branch }
        }.to change{Branch.count}.by(1)
      end
    end

    context 'with invalid parameters' do 
      before(:each) do
        @new_branch = FactoryBot.attributes_for(:invalid_branch)
      end

      it 'returns a success response' do
        post :create, params: { branch: @new_branch }
        expect(response).to be_successful
      end

      it 'does not create a new branch' do 
        expect{
          post :create, params: { branch: @new_branch }
        }.not_to change{Branch.count}
      end
    end
  end

  describe 'PUT #update' do
    context 'when the branch exists' do
      before(:each) do
        @branch = FactoryBot.create(:branch)
      end

      context 'with valid params' do
        before(:each) do
          @params = FactoryBot.attributes_for(:branch)
          put :update, params: {id: @branch.id, branch: @params}
        end

        it 'redirects to the branch page' do
          expect(response).to redirect_to branch_path(@branch)
        end

        it 'updates the branch' do
          expect(@branch.reload.version).to eq(@params[:version])
        end
      end

      context 'with invalid params' do
        before(:each) do
          @params = FactoryBot.attributes_for(:invalid_branch)
          put :update, params: {id: @branch.id, branch: @params}
        end

        it 'returns a successful response' do
          expect(response).to be_successful
        end

        it 'does not update the branch' do
          @branch.reload
          expect(@branch.version).not_to eq(@params[:version])
        end
      end
    end

    context 'when the branch does not exist' do
      before(:each) do
        @params = FactoryBot.attributes_for(:branch)
        put :update, params: {id: invalid_id, branch: @params}
      end

      it 'redirects to the branches page' do
        expect(response).to redirect_to branches_path
      end
    end
  end

  describe 'DELETE #destroy' do

    context 'when the branch exists' do 
      before(:each) do
        @branch = FactoryBot.create(:branch)
      end

      it 'redirects to branches page' do
        delete :destroy, params: { id: @branch.id }
      end
  
      it 'deletes the branch' do
        expect {
          delete :destroy, params: { id: @branch.id }
        }.to change{Branch.count}.by(-1)
      end
    end
    
    context 'when the branch does not exist' do
      it 'redirects to branches page' do
        delete :destroy, params: { id: invalid_id }
        expect(response).to redirect_to branches_path
      end
  
      it 'does not delete any branch' do
        expect {
          delete :destroy, params: { id: invalid_id }
        }.not_to change{Branch.count}
      end
    end
  end
  
end