require 'rails_helper'
require 'shoulda/matchers'

RSpec.describe 'follow_relationshipモデルのテスト', type: :model do
  subject { active }

  let(:user) { create(:user) }
  let(:other_user) { create(:other_user) }
  let(:active) { user.active_relationships.build(followed_id: other_user.id) }

  # リレーションシップの有効性
  it { should be_valid }

  describe 'バリデーションのテスト' do
    context 'followed_idが存在している' do
      it { is_expected.to validate_presence_of :followed_id }
    end

    context 'follower_idが存在している' do
      it { is_expected.to validate_presence_of :follower_id }
    end
  end
end
