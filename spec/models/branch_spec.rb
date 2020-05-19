require 'rails_helper'

RSpec.describe Branch, type: :model do

  describe 'Structure' do
    it { is_expected.to have_db_column(:version).of_type(:string)}
    it { is_expected.to validate_presence_of(:version) }
    it { is_expected.to validate_uniqueness_of(:version) }
    it { is_expected.to have_many(:pages) }
  end

  def generate_paths_list(size)
    paths_list = []
    size.times do
      paths_list.push(Faker::File.dir)
    end
    return paths_list
  end
  
  describe '.update_pages' do
    before(:each) do
      @branch = FactoryBot.create(:branch)
    end

    it 'adds all pages when the branch was empty' do
      paths = generate_paths_list(10)
      @branch.update_pages(paths)
      expect(@branch.pages.count).to eq(10)
    end

    it 'deletes all branch pages when the received list is empty' do
      FactoryBot.create_list(:page, 10, branch: @branch)
      @branch.update_pages([])
      expect(@branch.pages.count).to eq(0)
    end

    it 'deletes the branch pages that are not included in the list' do
      FactoryBot.create_list(:page, 10, branch: @branch)
      paths_list = @branch.pages.pluck(:path)[0..7]
      @branch.update_pages(paths_list)
      expect(@branch.pages.count).to eq(8)
    end

    it 'creates the branch pages that are included in the list and do not exist yet' do
      FactoryBot.create_list(:page, 10, branch: @branch)
      paths_list = @branch.pages.pluck(:path).concat(generate_paths_list(5))
      @branch.update_pages(paths_list)
      expect(@branch.pages.count).to eq(15)
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

  describe '.previous' do
    before(:each) do
      FactoryBot.create(:branch, version: '3.7')
      FactoryBot.create(:branch, version: '3.11')
      FactoryBot.create(:branch, version: '4.0')
    end


    it 'returns nil when called on the first branch' do
      branch = Branch.where(version: '3.7').first
      expect(branch.previous).to be_nil
    end

    it 'returns nil when called on a branch that is not saved' do
      branch = FactoryBot.build(:branch, version: '3.9')
      expect(branch.previous).to be_nil
    end

    it 'returns the previous branch when called in a branch that is not the first' do
      branch = Branch.where(version: '3.11').first
      expect(branch.previous.version).to eq('3.7')
    end
  end

  describe '.next' do
    before(:each) do
      FactoryBot.create(:branch, version: '3.7')
      FactoryBot.create(:branch, version: '3.11')
      FactoryBot.create(:branch, version: '4.0')
    end


    it 'returns nil when called on the last branch' do
      branch = Branch.where(version: '4.0').first
      expect(branch.next).to be_nil
    end

    it 'returns nil when called on a branch that is not saved' do
      branch = FactoryBot.build(:branch, version: '3.9')
      expect(branch.next).to be_nil
    end

    it 'returns the next branch when called in a branch that is not the last' do
      branch = Branch.where(version: '3.11').first
      expect(branch.next.version).to eq('4.0')
    end
  end

  describe '.new_pages' do

    before(:each) do
      FactoryBot.create(:branch, version: '3.7')
      FactoryBot.create(:branch, version: '3.11')
      FactoryBot.create(:branch, version: '4.0')
    end

    it 'returns all pages when its the first branch' do
      branch = Branch.find_by(version: '3.7')
      FactoryBot.create_list(:page, 10, branch: branch)
      expect(branch.new_pages.count).to eq(branch.pages.count)
    end

    it 'returns an empty list if it has no pages' do
      branch = Branch.find_by(version: '3.11')
      branch.pages.destroy_all
      expect(branch.new_pages.count).to eq(0)
    end

    it 'returns an empty list if it has the same pages as the previous branch' do
      previous_branch = Branch.find_by(version: '3.7')
      branch = Branch.find_by(version: '3.11')
      FactoryBot.create_list(:page, 10, branch: branch)
      branch.pages.each do |page|
        previous_branch.pages.create(path: page.path)
      end
      expect(branch.new_pages.count).to eq(0)
    end

    it 'returns the difference between the previous branch and the new branch' do
      previous_branch = Branch.find_by(version: '3.7')
      branch = Branch.find_by(version: '3.11')
      FactoryBot.create_list(:page, 10, branch: branch)
      branch.pages.each do |page|
        previous_branch.pages.create(path: page.path)
      end
      FactoryBot.create_list(:page, 5, branch: branch)
      expect(branch.new_pages.count).to eq(5)
    end
  end
  
end
