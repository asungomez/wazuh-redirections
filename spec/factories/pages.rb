FactoryBot.define do
  factory :page do
    path { Faker::File.dir }
    branch
  end
end
