require 'rails_helper'

RSpec.describe Redirection, type: :model do
  describe 'Validations' do
    describe 'destinations_must_be_from_different_branches' do
      it 'allows a new destination in a different branch' do
        origin = FactoryBot.create(:page)
        destination1 = FactoryBot.create(:page)
        destination2 = FactoryBot.create(:page)
        Redirection.create(from: origin.id, to: destination1.id)

        redirection = Redirection.new(from: origin.id, to: destination2.id)
        expect(redirection.save).to be_truthy
      end

      it 'does not allow a destination to the same branch without origin anchor' do
        origin = FactoryBot.create(:page)
        destination1 = FactoryBot.create(:page)
        destination2 = FactoryBot.create(:page, branch: destination1.branch)
        Redirection.create(from: origin.id, to: destination1.id)

        redirection = Redirection.new(from: origin.id, to: destination2.id)
        expect(redirection.save).to be_falsey
      end

      it 'allows a destination to the same branch but a new origin anchor' do
        origin = FactoryBot.create(:page)
        destination1 = FactoryBot.create(:page)
        destination2 = FactoryBot.create(:page, branch: destination1.branch)
        Redirection.create(from: origin.id, to: destination1.id)

        redirection = Redirection.new(from: origin.id, to: destination2.id, origin_anchor: 'something')
        expect(redirection.save).to be_truthy
      end

      it 'does not allow a destination to the same branch with an existing anchor' do
        origin = FactoryBot.create(:page)
        destination1 = FactoryBot.create(:page)
        destination2 = FactoryBot.create(:page, branch: destination1.branch)
        Redirection.create(from: origin.id, to: destination1.id, origin_anchor: 'something')

        redirection = Redirection.new(from: origin.id, to: destination2.id, origin_anchor: 'something')
        expect(redirection.save).to be_falsey
      end
    end
  end
end
