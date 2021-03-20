require 'rails_helper'

RSpec.describe 'Commentモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { comment.valid? }

    let(:user) { create(:user) }
    let(:spot) { create(:spot, user_id: user.id) }
    let!(:comment) { build(:comment, user_id: user.id, spot_id: spot.id) }

    context 'commentカラム' do
      it '空欄でないこと' do
        comment.comment = ''
        is_expected.to eq false
      end
      it '200文字以下であること: 200文字は〇' do
        comment.comment = Faker::Lorem.characters(number: 200)
        is_expected.to eq true
      end
      it '200文字以下であること: 201文字は×' do
        comment.comment = Faker::Lorem.characters(number: 201)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Userモデルとの関係' do
      it 'N:1となっている' do
        expect(Comment.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end
    context 'Spotモデルとの関係' do
      it 'N:1となっている' do
        expect(Comment.reflect_on_association(:spot).macro).to eq :belongs_to
      end
    end
  end
end