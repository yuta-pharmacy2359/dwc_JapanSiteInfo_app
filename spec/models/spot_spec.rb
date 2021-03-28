require 'rails_helper'

RSpec.describe 'Spotモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { spot.valid? }

    let(:user) { create(:user) }
    let!(:spot) { build(:spot, user_id: user.id) }

    context 'titleカラム' do
      it '空欄でないこと' do
        spot.title = ''
        is_expected.to eq false
      end
      it '20文字以下であること: 20文字は〇' do
        spot.title = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      it '20文字以下であること: 21文字は×' do
        spot.title = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
    end

    context 'prefectureカラム' do
      it '未選択でないこと' do
        spot.prefecture = nil
        is_expected.to eq false
      end
    end

    context 'cityカラム' do
      it '空欄でないこと' do
        spot.city = ''
        is_expected.to eq false
      end
      it '15文字以下であること: 15文字は〇' do
        spot.city = Faker::Lorem.characters(number: 15)
        is_expected.to eq true
      end
      it '15文字以下であること: 16文字は×' do
        spot.city = Faker::Lorem.characters(number: 16)
        is_expected.to eq false
      end
    end

    context 'visited_dayカラム' do
      it '未来の日付でないこと' do
        spot.visited_day = Date.today + 1
        is_expected.to eq false
      end
    end

    context 'contentカラム' do
      it '空欄でないこと' do
        spot.content = ''
        is_expected.to eq false
      end
      it '300文字以下であること: 300文字は〇' do
        spot.content = Faker::Lorem.characters(number: 300)
        is_expected.to eq true
      end
      it '300文字以下であること: 301文字は×' do
        spot.content = Faker::Lorem.characters(number: 301)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Userモデルとの関係' do
      it 'N:1となっている' do
        expect(Spot.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context 'KeywordRelationshipモデルとの関係' do
      it '1:Nとなっている' do
        expect(Spot.reflect_on_association(:keyword_relationships).macro).to eq :has_many
      end
    end

    context 'Keywordモデルとの関係' do
      it '1:Nとなっている' do
        expect(Spot.reflect_on_association(:keywords).macro).to eq :has_many
      end
    end

    context 'Commentモデルとの関係' do
      it '1:Nとなっている' do
        expect(Spot.reflect_on_association(:comments).macro).to eq :has_many
      end
    end

    context 'Favoriteモデルとの関係' do
      it '1:Nとなっている' do
        expect(Spot.reflect_on_association(:favorites).macro).to eq :has_many
      end
    end
  end
end
