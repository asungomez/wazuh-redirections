class PagesController < ApplicationController
  before_action :set_branch, only: [:edit_redirection]
  before_action :set_page, only: [:edit_redirection]

  def edit_redirection
  end

  def rename_page
    @origin = Page.find(params[:origin_id])
    @destination = Page.find(params[:destination_id])
    @origin.redirect_to(@destination)
    @destination.redirect_to(@origin)
    redirect_to renamed_pages_branch_path(@destination.branch)
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
      redirect_to branch_path(@branch)
    end
end
