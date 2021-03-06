class BranchesController < ApplicationController
  before_action :set_branch, except: [:index, :new, :create]

  # GET /branches
  # GET /branches.json
  def index
    @branches = Branch.ordered
  end

  # GET /branches/1
  # GET /branches/1.json
  def show
    redirect_to new_pages_branch_path(@branch)
  end

  # GET /branches/new
  def new
    @branch = Branch.new
  end

  # GET /branches/1/edit
  def edit
  end

  # POST /branches
  # POST /branches.json
  def create
    @branch = Branch.new(branch_params)

    respond_to do |format|
      if @branch.save
        format.html { redirect_to @branch, notice: 'Branch was successfully created.' }
        format.json { render :show, status: :created, location: @branch }
      else
        format.html { render :new }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /branches/1
  # PATCH/PUT /branches/1.json
  def update
    respond_to do |format|
      if @branch.update(branch_params)
        format.html { redirect_to @branch, notice: 'Branch was successfully updated.' }
        format.json { render :show, status: :ok, location: @branch }
      else
        format.html { render :edit }
        format.json { render json: @branch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /branches/1
  # DELETE /branches/1.json
  def destroy
    @branch.destroy
    respond_to do |format|
      format.html { redirect_to branches_url, notice: 'Branch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /branches/1/refresh
  def refresh
    @branch.update_pages(PagesDownloader.download(@branch.version)) 
    redirect_to branch_path(@branch), notice: @branch.pages.count > 0 ? 'Branch pages succesfully reloaded' : 'This branch does not have any documentation pages'
  end

  def new_pages 
    @pages = @branch.new_pages
  end

  def deleted_pages
    @pages = @branch.deleted_pages
  end

  def renamed_pages
    @pages = @branch.renamed_pages
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_branch
      @branch = Branch.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to branches_path, notice: 'This branch does not exist'
    end

    # Only allow a list of trusted parameters through.
    def branch_params
      params.require(:branch).permit(:version)
    end
end
