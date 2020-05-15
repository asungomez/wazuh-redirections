class Branch < ApplicationRecord
  validates :version, presence: true, uniqueness: true
end
