FactoryBot.define do
  factory :branch do
    version { Faker::App.semantic_version(major: 2..3) }
  end
end
