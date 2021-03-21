FactoryBot.define do
  factory :spot do
    title { Faker::Lorem.characters(number: 10) }
    prefecture {'東京都'}
    city { Faker::Lorem.characters(number: 5) }
    visited_day {'2020-01-01'}
    rate {'5'}
    spot_image1 {'assets/image1.jpg'}
    spot_image2 {'assets/image2.jpg'}
    spot_image3 {'assets/image3.jpg'}
    content { Faker::Lorem.characters(number: 50) }
    user
    after(:create) do |spot|
      create(:keyword_relationship, spot: spot, keyword: create(:keyword))
    end
  end
end
