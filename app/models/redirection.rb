class Redirection < ApplicationRecord
  belongs_to :origin, class_name: 'Page', foreign_key: 'from', inverse_of: :origin_redirections
  belongs_to :destination, class_name: 'Page', foreign_key: 'to', inverse_of: :destination_redirections

  validates :from, presence: true
  validates :to, presence: true
  validate :destinations_must_be_from_different_branches

  def destinations_must_be_from_different_branches
    destination_branch = Page.find(to).branch 
    previous_redirections = Redirection.where(
      from: from, 
      to: destination_branch.pages.pluck(:id), 
      origin_anchor: origin_anchor
    )
    unless previous_redirections.empty?
      errors.add(:to, "An origin URL can only have one redirection destination per branch")
    end
  end
end
