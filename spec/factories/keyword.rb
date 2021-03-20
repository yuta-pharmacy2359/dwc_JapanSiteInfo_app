FactoryBot.define do
  factory :keyword do
    keyword { Faker::Lorem.characters(number: 5) }
    spot
  end
end