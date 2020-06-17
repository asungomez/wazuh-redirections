class Page < ApplicationRecord
  belongs_to :branch

  has_many :origin_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :origin, foreign_key: 'to'

  has_many :destination_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :destination, foreign_key: 'from'

  has_many :origins, through: :origin_redirections, class_name: 'Page', inverse_of: :origins

  has_many :destinations, through: :destination_redirections, class_name: 'Page', inverse_of: :destinations

  scope :added, ->  (branch_from, branch_to) { branch_to.pages.where.not(path: branch_from.pages.pluck(:path)) }
  scope :removed, ->  (branch_from, branch_to) { branch_from.pages.where.not(path: branch_to.pages.pluck(:path)) }

  def destination_in(branch, origin_anchor = nil)
    if origin_anchor
      destination_with_anchor = destinations.find_by(id: redirections_to(branch).where(origin_anchor: origin_anchor).pluck(:to))
      if destination_with_anchor
        return destination_with_anchor
      end
    end
    return destinations.find_by(branch: branch)
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

  def make_renamed(page, options = {previous_anchor: nil, current_anchor: nil})
    if page 
      redirections_to(page.branch).where(origin_anchor: options[:current_anchor]).destroy_all
      redirections_from(page.branch).where(destination_anchor: options[:current_anchor]).destroy_all
      redirect_to(page, origin_anchor: options[:current_anchor], destination_anchor: options[:previous_anchor])
      page.redirect_to(self, origin_anchor: options[:previous_anchor], destination_anchor: options[:current_anchor])
    end
  end

  def origins_from(branch, destination_anchor = nil)
    Page.where(id: redirections_from(branch).where(destination_anchor: destination_anchor).pluck(:from))
  end

  def redirect_to(destination, options = {origin_anchor: nil, destination_anchor: nil})
    redirections_to(destination.branch).destroy_by(origin_anchor: options[:origin_anchor])
    Redirection.create(
      from: id, 
      to: destination.id, 
      origin_anchor: options[:origin_anchor], 
      destination_anchor: options[:destination_anchor]
    )
  end

  def redirections_from(branch)
    Redirection.where(to: id, from: branch.pages.pluck(:id))
  end

  def redirections_to(branch)
    Redirection.where(from: id, to: branch.pages.pluck(:id))
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
