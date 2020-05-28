FactoryBot.define do
  factory :page do
    transient do
      version { nil }
    end

    path    { Faker::File.dir }
    branch  { version ? Branch.find_by(version: version) || FactoryBot.create(:branch, version: version) : FactoryBot.create(:branch) }
  end
end
