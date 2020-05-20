class Redirection < ApplicationRecord
  belongs_to :origin, class_name: 'Page', foreign_key: 'from', inverse_of: :origin_redirections
  belongs_to :destination, class_name: 'Page', foreign_key: 'to', inverse_of: :destination_redirections
end
