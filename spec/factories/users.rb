FactoryBot.define do
  factory :user do
    fullname { Faker::Lorem.characters(number: 10) }
    nickname { Faker::Lorem.characters(number: 10) }
    sex {'男性'}
    birthday {'2000-01-01'}
    prefecture {'東京都'}
    city { Faker::Lorem.characters(number: 5) }
    email { Faker::Internet.email }
    introduction { Faker::Lorem.characters(number: 20) }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
