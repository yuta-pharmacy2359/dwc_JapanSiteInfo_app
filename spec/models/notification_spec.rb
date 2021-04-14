require 'rails_helper'

RSpec.describe 'Notificationモデルのテスト', type: :model do
  describe 'アソシエーションのテスト' do
    context 'Userモデルとの関係' do
      it 'serverとN:1となっている' do
        expect(Notification.reflect_on_association(:server).macro).to eq :belongs_to
      end
      it 'hostN:1となっている' do
        expect(Notification.reflect_on_association(:host).macro).to eq :belongs_to
      end
    end
    
    context 'Spotモデルとの関係' do
      it 'N:1となっている' do
        expect(Notification.reflect_on_association(:spot).macro).to eq :belongs_to
      end
    end
    
    context 'Commentモデルとの関係' do
      it '1:1となっている' do
        expect(Notification.reflect_on_association(:comment).macro).to eq :belongs_to
      end
    end
    
  end
end