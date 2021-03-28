require 'rails_helper'

RSpec.describe 'Keywordモデルのテスト', type: :model do
  describe 'アソシエーションのテスト' do
    context 'Keyword_relationshipモデルとの関係' do
      it '1:Nとなっている' do
        expect(Keyword.reflect_on_association(:keyword_relationships).macro).to eq :has_many
      end
    end

    context 'Spotモデルとの関係' do
      it '1:Nとなっている' do
        expect(Keyword.reflect_on_association(:spots).macro).to eq :has_many
      end
    end
  end
end
