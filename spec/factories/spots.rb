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

    factory :search_spot do
      title { 'ディズニーランド' }
      prefecture { '千葉県' }
      city { '浦安市' }
      visited_day {'2020-01-01'}
      rate {'5'}
    end

    factory :search_spot2 do
      title { '稲荷山古墳' }
      prefecture { '埼玉県' }
      city { '行田市' }
      visited_day {'2021-01-01'}
      rate {'4'}
    end

    factory :search_spot3 do
      title { '大仙陵古墳' }
      prefecture { '大阪府' }
      city { '堺市' }
      visited_day {'2019-01-01'}
      rate {'3'}
    end
  end
end
