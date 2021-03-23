FactoryBot.define do
  factory :spot do
    title { Faker::Lorem.characters(number: 10) }
    prefecture {'東京都'}
    city { Faker::Lorem.characters(number: 5) }
    visited_day {'2020-01-01'}
    rate {'5'}
    spot_image1  {File.open("#{Rails.root}/app/assets/images/image1.jpg")}
    spot_image2  {File.open("#{Rails.root}/app/assets/images/image2.jpg")}
    spot_image3  {File.open("#{Rails.root}/app/assets/images/image3.jpg")}
    content { Faker::Lorem.characters(number: 50) }
    user
    
    factory :other_spot do
      prefecture {'神奈川県'}
      visited_day {'2019-01-01'}
      rate {'4'}
      spot_image1  {File.open("#{Rails.root}/app/assets/images/image4.jpg")}
      spot_image2  {File.open("#{Rails.root}/app/assets/images/image5.jpg")}
      spot_image3  {File.open("#{Rails.root}/app/assets/images/image6.jpg")}
    end
  end
end
