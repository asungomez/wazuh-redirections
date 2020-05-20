class Redirection < ApplicationRecord
  belongs_to :origin, class_name: 'Page', foreign_key: 'from', inverse_of: :origin_redirections
  belongs_to :destination, class_name: 'Page', foreign_key: 'to', inverse_of: :destination_redirections

  validates :from, presence: true
  validates :to, presence: true, uniqueness: {scope: :from}
  validate :destinations_must_be_from_different_branches

  def destinations_must_be_from_different_branches
    origin = Page.find(from)
    destination = Page.find(to)
    if origin.destinations.pluck(:branch_id).include?(destination.branch_id)
      errors.add(:to, "A page can only have one redirection destination per branch")
    end
  end
end
