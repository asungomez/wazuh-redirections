require 'rails_helper'

RSpec.describe PagesDownloader do

  describe '.download' do
    it 'downloads a full list of paths when the page exists' do
      expect(PagesDownloader.download('3.12').count).to be > 0
    end

    it 'downloads an empty list when the pages does not exist' do
      expect(PagesDownloader.download('0.0').count).to eq(0)
    end
  end
end