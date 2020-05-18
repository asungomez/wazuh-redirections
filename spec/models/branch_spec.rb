require 'rails_helper'

RSpec.describe Branch, type: :model do

  describe 'Structure' do
    it { is_expected.to have_db_column(:version).of_type(:string)}
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_uniqueness_of(:version) }
    it { is_expected.to have_many(:pages) }
  end
  
  describe '.refresh' do
    it 'loads a page list when the version number exists' do
      branch = FactoryBot.create(:branch, version: '3.12')
      branch.refresh 
      # This is the number of pages the 3.12 branch currently has. This test will break if this page number changes, 
      # so when it fails, it needs to be revisited to assert if the failure is caused by the code or by a structure 
      # change in the remote documentation
      pages_in_branch = 513
      expect(branch.pages.count).to eq(pages_in_branch) 
    end

    it 'creates an empty page list when the version number does not exist' do
      branch = FactoryBot.create(:branch, version: '1.2')
      branch.refresh 
      expect(branch.pages.count).to eq(0)
    end
  end

  describe '.sorting_value' do 
    it 'returns bigger value for next major version' do
      smaller = FactoryBot.build(:branch, version: '3.0')
      bigger = FactoryBot.build(:branch, version: '4.0')
      expect(smaller.sorting_value).to be < bigger.sorting_value
    end

    it 'returns bigger value for next minor version' do
      smaller = FactoryBot.build(:branch, version: '3.9')
      bigger = FactoryBot.build(:branch, version: '3.10')
      expect(smaller.sorting_value).to be < bigger.sorting_value
    end

    it 'returns same value for same version' do
      branch1 = FactoryBot.build(:branch, version: '3.9')
      branch2 = FactoryBot.build(:branch, version: '3.9')
      expect(branch1.sorting_value).to eq(branch2.sorting_value)
    end
  end
  
end
