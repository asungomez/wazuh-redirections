class Page < ApplicationRecord
  belongs_to :branch

  has_many :origin_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :origin, foreign_key: 'to'

  has_many :destination_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :destination, foreign_key: 'from'

  has_many :origins, through: :origin_redirections, class_name: 'Page', inverse_of: :origins

  has_many :destinations, through: :destination_redirections, class_name: 'Page', inverse_of: :destinations

  scope :added, ->  (branch_from, branch_to) { branch_to.pages.where.not(path: branch_from.pages.pluck(:path)) }
  scope :removed, ->  (branch_from, branch_to) { branch_from.pages.where.not(path: branch_to.pages.pluck(:path)) }

  def destination_in(branch)
    destinations.find_by(branch: branch)
  end

  def is_deleted?
    branch.next ? branch.next.deleted_pages.include?(self) : false
  end

  def is_new?
    branch.new_pages.include?(self)
  end

  def is_renamed?
    branch.renamed_pages.include?(self)
  end

  def make_new
    Redirection.destroy_by(from: origins_from(branch.previous).pluck(:id), to: id)
    Redirection.destroy_by(to: origins_from(branch.previous).pluck(:id), from: id)
  end

  def make_renamed(page)
    if page 
      make_new
      redirect_to page 
      page.redirect_to self
    end
  end

  def origins_from(branch)
    origins.where(branch: branch)
  end

  def redirect_to(destination)
    current_destination = destination_in(destination.branch)
    if current_destination
      Redirection.destroy_by(from: id, to: current_destination.id)
    end
    Redirection.create(from: id, to: destination.id)
  end

  def type(branch)
    if self.branch == branch
      if is_new?
        'new'
      elsif is_renamed?
        'renamed'
      end
    elsif is_deleted?
      'deleted'
    end
  end
end
