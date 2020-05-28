class PagesController < ApplicationController
  before_action :set_branch, only: [:edit_redirection]
  before_action :set_page, except: [:rename_page]

  def edit_redirection
  end

  def mark_as_new
    @page.make_new
    redirect_to new_pages_branch_path(@page.branch)
  end

  def rename_page
    origin = Page.find(params[:origin_id])
    destination = Page.find(params[:destination_id])
    destination.make_renamed(origin)
    redirect_to renamed_pages_branch_path(destination.branch)
  rescue ActiveRecord::RecordNotFound
    redirect_to branches_path, notice: 'The specified path does not exist'
  end

  private

    def set_branch
      @branch = Branch.find(params[:branch_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to branches_path, notice: 'This branch does not exist'
    end

    def set_page
      @page = Page.find(params[:page_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to @branch ? branch_path(@branch) : branches_path
    end
end
