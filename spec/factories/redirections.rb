FactoryBot.define do
  factory :redirection do
    from               { FactoryBot.create(:page).id }
    to                 { FactoryBot.create(:page).id }
    origin_anchor      { Faker::Beer.brand }
    destination_anchor { Faker::Beer.brand }
  end
end
