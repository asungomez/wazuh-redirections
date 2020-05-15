require 'rails_helper'

RSpec.describe Branch, type: :model do
  it { is_expected.to have_db_column(:version).of_type(:string)}
  it { is_expected.to validate_presence_of(:version) }
  it { is_expected.to validate_uniqueness_of(:version) }
end
