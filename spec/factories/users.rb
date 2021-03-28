FactoryBot.define do
  factory :user do
    fullname { Faker::Lorem.characters(number: 10) }
    nickname { Faker::Lorem.characters(number: 10) }
    sex { '男性' }
    birthday { '1990-01-01' }
    prefecture { '東京都' }
    city { Faker::Lorem.characters(number: 5) }
    email { Faker::Internet.email }
    profile_image { File.open("#{Rails.root}/app/assets/images/image7.jpg") }
    introduction { Faker::Lorem.characters(number: 20) }
    password { 'password' }
    password_confirmation { 'password' }

    factory :other_user do
      sex { '女性' }
      birthday { '2000-01-01' }
      prefecture { '大阪府' }
      profile_image { File.open("#{Rails.root}/app/assets/images/image8.jpg") }
    end

    factory :other_user2 do
      birthday { '1995-01-01' }
      prefecture { '沖縄県' }
      profile_image { File.open("#{Rails.root}/app/assets/images/image9.jpg") }
    end

    factory :search_user do
      nickname { 'ハナコ' }
      sex { '女性' }
      birthday { '1990-01-01' }
      prefecture { '千葉県' }
      city { '南房総市' }
    end

    factory :search_user2 do
      nickname { 'タロー' }
      birthday { '1980-01-01' }
      prefecture { '埼玉県' }
      city { '所沢市' }
    end
  end
end
