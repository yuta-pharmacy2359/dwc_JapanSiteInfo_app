require 'rails_helper'

describe '[STEP3] 仕上げのテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:spot) { create(:spot, user: user) }
  let!(:other_spot) { create(:spot, user: other_user) }

  describe 'サクセスメッセージのテスト' do
    subject { page }

    it 'ユーザ新規登録成功時' do
      visit new_user_registration_path
      fill_in 'user[fullname]', with: Faker::Lorem.characters(number: 10)
      fill_in 'user[nickname]', with: Faker::Lorem.characters(number: 10)
      fill_in 'user[email]', with: 'a' + user.email
      choose('user_sex_male')
      fill_in 'user[birthday]', with: '2000-01-01'
      select '東京都', from: 'user_prefecture'
      fill_in 'user[city]', with: Faker::Lorem.characters(number: 10)
      fill_in 'user[password]', with: 'password'
      fill_in 'user[password_confirmation]', with: 'password'
      click_button '新規登録'
      is_expected.to have_content 'ようこそ！ アカウントが登録されました'
    end
    it 'ユーザログイン成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      is_expected.to have_content 'ログインしました'
    end
    it 'ユーザログアウト成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      logout_link = find_all('a')[9].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
      is_expected.to have_content 'ログアウトしました'
    end
    it 'ユーザのプロフィール情報更新成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      visit edit_user_path(user)
      click_button '更新する'
      is_expected.to have_content 'プロフィールを更新しました'
    end
    it '投稿データの新規投稿成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      visit new_spot_path
      fill_in 'spot[title]', with: Faker::Lorem.characters(number: 10)
      select '東京都', from: 'spot_prefecture'
      fill_in 'spot[city]', with: Faker::Lorem.characters(number: 10)
      fill_in 'spot[visited_day]', with: '2021-01-01'
      find('input[@name="spot[rate]"]', visible: false).set('5')
      attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
      attach_file "spot[spot_image2]", "app/assets/images/image2.jpg"
      attach_file "spot[spot_image3]", "app/assets/images/image3.jpg"
      fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
      click_button '投稿する'
      is_expected.to have_content 'スポットを投稿しました'
    end
    it '投稿データの更新成功時' do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      visit edit_spot_path(spot)
      click_button '更新する'
      is_expected.to have_content 'スポットを更新しました'
    end
  end

  describe '処理失敗時のテスト' do
    context 'ユーザ新規登録失敗: 誕生日を未来の日付にする' do
      before do
        visit new_user_registration_path
        @fullname = Faker::Lorem.characters(number: 10)
        @nickname = Faker::Lorem.characters(number: 10)
        @email = 'a' + user.email
        @sex = 'user_sex_male'
        @birthday = '2112-01-01'
        @prefecture = '東京都'
        @city = Faker::Lorem.characters(number: 10)
        fill_in 'user[fullname]', with: @fullname
        fill_in 'user[nickname]', with: @nickname
        fill_in 'user[email]', with: @email
        choose(@sex)
        fill_in 'user[birthday]', with: @birthday
        select @prefecture, from: 'user_prefecture'
        fill_in 'user[city]', with: @city
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '新規登録されない' do
        expect { click_button '新規登録' }.not_to change(User.all, :count)
      end
      it '新規登録画面を表示しており、フォームの内容が正しい' do
        click_button '新規登録'
        expect(page).to have_content '新規登録'
        expect(page).to have_field 'user[fullname]', with: @fullname
        expect(page).to have_field 'user[nickname]', with: @nickname
        expect(page).to have_field 'user[email]', with: @email
        expect(page).to have_checked_field @sex
        expect(page).to have_field 'user[birthday]', with: @birthday
        expect(page).to have_select('都道府県', selected: @prefecture)
        expect(page).to have_field 'user[city]', with: @city
      end
      it 'バリデーションエラーが表示される' do
        click_button '新規登録'
        expect(page).to have_content "誕生日が無効な日付です"
      end
    end

    context 'ユーザのプロフィール情報編集失敗: 誕生日を未来の日付にする' do
      before do
        @user_old_birthday = user.birthday
        @birthday = "2112-01-01"
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit edit_user_path(user)
        fill_in 'user[birthday]', with: @birthday
        click_button '更新する'
      end

      it '更新されない' do
        expect(user.reload.birthday).to eq @user_old_birthday
      end
      it 'ユーザ編集画面を表示しており、フォームの内容が正しい' do
        expect(page).to have_field 'user[fullname]', with: user.fullname
        expect(page).to have_field 'user[nickname]', with: user.nickname
        expect(page).to have_field 'user[email]', with: user.email
        expect(page).to have_checked_field 'edit_user_sex_male'
        expect(page).to have_field 'user[birthday]', with: @birthday
        expect(page).to have_select('都道府県', selected: '東京都')
        expect(page).to have_field 'user[city]', with: user.city
        expect(page).to have_selector("img[src$='profile_image.jpeg']")
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it 'バリデーションエラーが表示される' do
        expect(page).to have_content "誕生日が無効な日付です"
      end
    end

    context '投稿データの新規投稿失敗: タイトルを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit new_spot_path
        @city = Faker::Lorem.characters(number: 10)
        @visited_day = '2021-01-01'
        @content = Faker::Lorem.characters(number: 50)
        select '東京都', from: 'spot_prefecture'
        fill_in 'spot[city]', with: @city
        fill_in 'spot[visited_day]', with: @visited_day
        find('input[@name="spot[rate]"]', visible: false).set('5')
        fill_in 'spot[content]', with: @content
      end

      it '投稿が保存されない' do
        expect { click_button '投稿する' }.not_to change(Spot.all, :count)
      end
      it '新規投稿フォームの内容が正しい' do
        click_button '投稿する'
        expect(find_field('spot[title]').text).to be_blank
        expect(page).to have_select('都道府県', selected: '東京都')
        expect(page).to have_field 'spot[city]', with: @city
        expect(page).to have_field 'spot[visited_day]', with: @visited_day
        expect(page).to have_field 'spot[content]', with: @content
      end
      it 'バリデーションエラーが表示される' do
        click_button '投稿する'
        expect(page).to have_content "タイトルを入力してください"
      end
    end

    context '投稿データの更新失敗: titleを空にする' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit edit_spot_path(spot)
        @spot_old_title = spot.title
        fill_in 'spot[title]', with: ''
        click_button '更新する'
      end

      it 'スポットが更新されない' do
        expect(spot.reload.title).to eq @spot_old_title
      end
      it 'スポット編集画面を表示しており、フォームの内容が正しい' do
        expect(current_path).to eq '/spots/' + spot.id.to_s
        expect(find_field('spot[title]').text).to be_blank
        expect(page).to have_select('都道府県', selected: '東京都')
        expect(page).to have_field 'spot[city]', with: spot.city
        expect(page).to have_field 'spot[visited_day]', with: spot.visited_day
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        expect(page).to have_selector("img[src$='spot_image2.jpeg']")
        expect(page).to have_selector("img[src$='spot_image3.jpeg']")
        expect(page).to have_field 'spot[content]', with: spot.content
      end
      it 'エラーメッセージが表示される' do
        expect(page).to have_content 'タイトルを入力してください'
      end
    end
  end

  describe 'ログインしていない場合のアクセス制限のテスト: アクセスできず、新規登録画面またはトップ画面に遷移する' do
    subject { current_path }

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to eq '/users/sign_up'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to eq '/users/sign_up'
    end
    it 'ユーザ情報編集画面' do
      visit edit_user_path(user)
      is_expected.to eq '/'
    end
    it '投稿編集画面' do
      visit edit_spot_path(spot)
      is_expected.to eq '/'
    end
    it 'キーワード一覧画面' do
      visit keywords_path
      is_expected.to eq '/users/sign_up'
    end
    it 'フォロー一覧画面' do
      visit following_user_path(user)
      is_expected.to eq '/users/sign_up'
    end
    it 'フォロワー一覧画面' do
      visit followers_user_path(user)
      is_expected.to eq '/users/sign_up'
    end
    it 'ランキング(スポット)画面' do
      visit spot_favorite_ranking_path
      is_expected.to eq '/users/sign_up'
    end
    it 'ランキング(ユーザー)画面' do
      visit user_favorite_ranking_path
      is_expected.to eq '/users/sign_up'
    end
  end

  describe '他人の画面のテスト' do
    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    describe '他人の投稿詳細画面のテスト' do
      before do
        visit spot_path(other_spot)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/spots/' + other_spot.id.to_s
        end
        it 'スポットのタイトルが表示される' do
          expect(page).to have_content other_spot.title
        end
        it 'スポットの都道府県が表示される' do
          expect(page).to have_content other_spot.prefecture
        end
        it 'スポットの市区町村が表示される' do
          expect(page).to have_content other_spot.city
        end
        it 'スポットの投稿日が表示される' do
          expect(page).to have_content other_spot.created_at.strftime("%Y年%-m月%-d日")
        end
        it 'スポットの来訪日が表示される' do
          expect(page).to have_content other_spot.visited_day.strftime("%Y年%-m月%-d日")
        end
        it 'スポットの評価が表示される', js: true do
          expect(page).to have_content other_spot.rate
          sleep 3
        end
        it 'スポットのいいねボタンが表示される' do
          expect(page).to have_link '', href: spot_favorites_path(other_spot)
        end
        it '自分のスポットのいいね数が表示される' do
          expect(page).to have_content other_spot.favorites.count
        end
        it 'スポットの画像(1枚目)が表示される' do
          expect(page).to have_selector("img[src$='spot_image1.jpeg']")
          expect(page).to have_selector("img[src$='spot_image2.jpeg']")
          expect(page).to have_selector("img[src$='spot_image3.jpeg']")
        end
        it 'スポットの内容が表示される' do
          expect(page).to have_content other_spot.content
        end
        it '投稿の編集リンクが表示されない' do
          expect(page).not_to have_link '編集する'
        end
        it '投稿の削除リンクが表示されない' do
          expect(page).not_to have_link '削除する'
        end
      end

      context 'サイドバーの確認' do
        it '「投稿者プロフィール」と表示されている' do
          expect(page).to have_content '投稿者プロフィール'
        end
        it '他人のプロフィール画像が表示される' do
          expect(page).to have_selector("img[src$='profile_image.jpeg']")
        end
        it '他人のニックネームが表示される' do
          expect(page).to have_content other_user.nickname
        end
        it '他人の性別が表示される' do
          expect(page).to have_content other_user.sex
        end
        it '他人の年齢が表示される' do
          expect(page).to have_content other_user.age
        end
        it '他人の住所が表示される' do
          expect(page).to have_content other_user.prefecture
          expect(page).to have_content other_user.city
        end
        it '自分の自己紹介が表示される' do
          expect(page).to have_content other_user.introduction
        end
        it '「プロフィールをみる」(ユーザー詳細画面へのリンク)が存在する' do
          expect(page).to have_link 'プロフィールをみる', href: user_path(other_user)
        end
      end
    end

    context '他人の投稿編集画面' do
      it '遷移できず、トップ画面にリダイレクトされる' do
        visit edit_spot_path(other_spot)
        expect(current_path).to eq '/'
      end
    end

    describe '他人のユーザ詳細画面のテスト' do
      before do
        visit user_path(other_user)
      end

      context '表示の確認' do
        it '「(他人のニックネーム名) さん」と表示されている' do
          expect(page).to have_content "#{other_user.nickname} さん"
        end
        it '他人のプロフィール画像が表示される' do
          expect(page).to have_selector("img[src$='profile_image.jpeg']")
        end
        it '他人のニックネームが表示される' do
          expect(page).to have_content other_user.nickname
        end
        it '他人の性別が表示される' do
        expect(page).to have_content other_user.sex
        end
        it '他人の年齢が表示される' do
          expect(page).to have_content other_user.age
        end
        it '他人の住所が表示される' do
          expect(page).to have_content other_user.prefecture
          expect(page).to have_content other_user.city
        end
        it '他人の自己紹介が表示される' do
          expect(page).to have_content other_user.introduction
        end
        it '他人のフォロー数がそれぞれ表示される' do
          expect(page).to have_content other_user.following.count
        end
        it '他人のフォロワー数がそれぞれ表示される' do
          expect(page).to have_content other_user.followers.count
        end
        it '他人のスポット数がそれぞれ表示される' do
          expect(page).to have_content other_user.spots.count
        end
        #it '自分の総いいね数が表示される' do
          #expect(page).to have_content other_user.all_user_favorites_count
        #end
        it '「フォローする」のボタンが存在する' do
          expect(page).to have_button 'フォローする'
        end
      end

      context 'サイドバーの確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/users/' + other_user.id.to_s
        end
        it 'スポット一覧に他人のスポットの画像(1枚目)が表示される' do
          expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        end
        it 'スポット一覧に他人のスポットのタイトルが表示され、リンクが正しい' do
          expect(page).to have_link other_spot.title, href: spot_path(other_spot)
        end
        it 'スポット一覧に他人のスポットの所在地が表示される' do
          expect(page).to have_content other_spot.prefecture
          expect(page).to have_content other_spot.city
        end
        it 'スポット一覧に他人のスポットの投稿日が表示される' do
          expect(page).to have_content other_spot.created_at.strftime("%Y年%-m月%-d日")
        end
        it 'スポット一覧に他人のスポットの来訪日が表示される' do
          expect(page).to have_content other_spot.visited_day.strftime("%Y年%-m月%-d日")
        end
        it 'スポット一覧に他人のスポットの評価が表示される', js: true do
          expect(page).to have_content other_spot.rate
          sleep 3
        end
        it '他人のスポットのいいねボタンが表示される' do
          expect(page).to have_link '', href: spot_favorites_path(other_spot)
        end
        it '他人のスポットのいいね数が表示される' do
          expect(page).to have_content other_spot.favorites.count
        end
        it '自分のスポットのタイトルは表示されない' do
          expect(page).not_to have_link spot.title, href: spot_path(spot)
        end
      end
    end

    context '他人のユーザ情報編集画面' do
      it '遷移できず、トップ画面にリダイレクトされる' do
        visit edit_user_path(other_user)
        expect(current_path).to eq '/'
      end
    end
  end
end
