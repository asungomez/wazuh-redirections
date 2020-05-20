class Page < ApplicationRecord
  belongs_to :branch

  has_many :origin_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :origin, foreign_key: 'to'

  has_many :destination_redirections, dependent: :destroy, class_name: 'Redirection', inverse_of: :destination, foreign_key: 'from'

  has_many :origins, through: :origin_redirections, class_name: 'Page', inverse_of: :origins

  has_many :destinations, through: :destination_redirections, class_name: 'Page', inverse_of: :destinations

  scope :added, ->  (branch_from, branch_to) { branch_to.pages.where.not(path: branch_from.pages.pluck(:path)) }
  scope :removed, ->  (branch_from, branch_to) { branch_from.pages.where.not(path: branch_to.pages.pluck(:path)) }
  

  def redirect_to(destination)
    current_destination = destination_in(destination.branch)
    if current_destination
      Redirection.destroy_by(from: id, to: current_destination.id)
    end
    Redirection.create(from: id, to: destination.id)
  end

  def destination_in(branch)
    destinations.find_by(branch: branch)
  end
end
