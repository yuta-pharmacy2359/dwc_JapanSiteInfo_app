require 'rails_helper'

RSpec.describe 'Userモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { user.valid? }

    let!(:other_user) { create(:user) }
    let(:user) { build(:user) }

    context 'fullnameカラム' do
      it '空欄でないこと' do
        user.fullname = ''
        is_expected.to eq false
      end
      it '20文字以下であること: 20文字は〇' do
        user.fullname = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      it '20文字以下であること: 21文字は×' do
        user.fullname = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
    end

    context 'nicknameカラム' do
      it '空欄でないこと' do
        user.nickname = ''
        is_expected.to eq false
      end
      it '20文字以下であること: 20文字は〇' do
        user.nickname = Faker::Lorem.characters(number: 20)
        is_expected.to eq true
      end
      it '20文字以下であること: 21文字は×' do
        user.nickname = Faker::Lorem.characters(number: 21)
        is_expected.to eq false
      end
      it '一意性があること' do
        user.nickname = other_user.nickname
        is_expected.to eq false
      end
    end

    context 'sexカラム' do
      it '未選択でないこと' do
        user.sex = nil
        is_expected.to eq false
      end
    end

    context 'birthdayカラム' do
      it '未選択でないこと' do
        user.birthday = nil
        is_expected.to eq false
      end
      it '未来の日付でないこと' do
        user.birthday = Date.today + 1
        is_expected.to eq false
      end
    end

    context 'prefectureカラム' do
      it '未選択でないこと' do
        user.prefecture = nil
        is_expected.to eq false
      end
    end

    context 'cityカラム' do
      it '空欄でないこと' do
        user.city = ''
        is_expected.to eq false
      end
      it '15文字以下であること: 15文字は〇' do
        user.city = Faker::Lorem.characters(number: 15)
        is_expected.to eq true
      end
      it '15文字以下であること: 16文字は×' do
        user.city = Faker::Lorem.characters(number: 16)
        is_expected.to eq false
      end
    end

    context 'introductionカラム' do
      it '50文字以下であること: 50文字は〇' do
        user.introduction = Faker::Lorem.characters(number: 50)
        is_expected.to eq true
      end
      it '50文字以下であること: 51文字は×' do
        user.introduction = Faker::Lorem.characters(number: 51)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Spotモデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:spots).macro).to eq :has_many
      end
    end

    context 'FollowRelationshipモデルとの関係' do
      it 'followingと1:Nとなっている' do
        expect(User.reflect_on_association(:following).macro).to eq :has_many
      end
      it 'followersと1:Nとなっている' do
        expect(User.reflect_on_association(:followers).macro).to eq :has_many
      end
    end

    context 'Commentモデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:comments).macro).to eq :has_many
      end
    end

    context 'Favoriteモデルとの関係' do
      it '1:Nとなっている' do
        expect(User.reflect_on_association(:favorites).macro).to eq :has_many
      end
    end
  end

  describe 'following, followers関連のテスト' do
    let(:user) { create(:user) }
    let(:other_user) { create(:other_user) }

    it 'following, followersの関係性が正しいか' do
      expect(user.following?(other_user)).to eq false
      user.follow(other_user)
      expect(user.following?(other_user)).to eq true
      expect(other_user.followers.include?(user)).to eq true
      user.unfollow(other_user)
      expect(user.following?(other_user)).to eq false
    end
  end
end
