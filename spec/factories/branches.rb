FactoryBot.define do
  factory :branch do
    version { Faker::App.unique.semantic_version(major: 2..3) }
  end
end
