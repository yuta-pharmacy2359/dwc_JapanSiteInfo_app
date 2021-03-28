require 'rails_helper'

describe '[STEP2] ユーザログイン後のテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:other_user) }
  let!(:spot) { create(:spot, user: user) }
  let!(:other_spot) { create(:other_spot, user: other_user) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認: ※「ログアウト」は『ユーザログアウトのテスト』でテスト済み' do
      subject { current_path }

      it '「JapanSiteInfo」を押すと、トップ画面に遷移する' do
        top_link = find_all('a')[0].native.inner_text
        top_link = top_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link top_link
        is_expected.to eq '/'
      end
      it '「(ニックネーム)さん」を押すと、マイページ画面に遷移する' do
        nickname_link = find_all('a')[1].native.inner_text
        nickname_link = nickname_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link nickname_link
        is_expected.to eq '/users/' + user.id.to_s
      end
      it '「マイページ」を押すと、マイページ画面に遷移する' do
        mypage_link = find_all('a')[2].native.inner_text
        mypage_link = mypage_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link mypage_link
        is_expected.to eq '/users/' + user.id.to_s
      end
      it '「新規投稿」を押すと、新規投稿画面に遷移する' do
        new_spot_link = find_all('a')[3].native.inner_text
        new_spot_link = new_spot_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link new_spot_link
        is_expected.to eq '/spots/new'
      end
      it '「スポット一覧」を押すと、スポット一覧画面に遷移する' do
        spots_link = find_all('a')[5].native.inner_text
        spots_link = spots_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link spots_link
        is_expected.to eq '/spots'
      end
      it '「キーワード一覧」を押すと、キーワード一覧画面に遷移する' do
        keywords_link = find_all('a')[6].native.inner_text
        keywords_link = keywords_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link keywords_link
        is_expected.to eq '/keywords'
      end
      it '「ユーザー一覧」を押すと、ユーザ一覧画面に遷移する' do
        users_link = find_all('a')[7].native.inner_text
        users_link = users_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link users_link
        is_expected.to eq '/users'
      end
      it '「ランキング」を押すと、いいね数ランキング(スポット)画面に遷移する' do
        ranking_link = find_all('a')[8].native.inner_text
        ranking_link = ranking_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link ranking_link
        is_expected.to eq '/rankings/spot_favorite'
      end
    end
  end

  describe 'トップ画面のテスト' do
    before do
      visit top_path
    end

    context '新着スポット画面のテスト' do
      it '「新着スポット」と表示されている' do
        expect(page).to have_content '新着スポット'
      end
      it 'スポットの画像(1枚目)が表示されている' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      end
      it '各スポットのタイトルが表示され、リンク先がそれぞれ正しい' do
        expect(page).to have_link spot.title, href: spot_path(spot)
        expect(page).to have_link other_spot.title, href: spot_path(other_spot)
      end
      it '各スポットの所在地が表示される' do
        expect(page).to have_content spot.prefecture
        expect(page).to have_content other_spot.prefecture
        expect(page).to have_content spot.city
        expect(page).to have_content other_spot.city
      end
      it '各スポットの投稿日が表示される' do
        expect(page).to have_content spot.created_at.strftime("%Y年%-m月%-d日")
        expect(page).to have_content other_spot.created_at.strftime("%Y年%-m月%-d日")
      end
      it '各スポットの来訪日が表示される' do
        expect(page).to have_content spot.visited_day.strftime("%Y年%-m月%-d日")
        expect(page).to have_content other_spot.visited_day.strftime("%Y年%-m月%-d日")
      end
      it '各スポットの評価が表示される', js: true do
        expect(page).to have_content spot.rate
        expect(page).to have_content other_spot.rate
        sleep 3
      end
      it '各スポットのいいねボタンが表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
        expect(page).to have_link '', href: spot_favorites_path(other_spot)
      end
      it '各スポットのいいね数が表示される' do
        expect(page).to have_content spot.favorites.count
        expect(page).to have_content other_spot.favorites.count
      end
    end

    it 'スポット検索エリアは表示されない' do
      expect(page).not_to have_content 'スポットを探してみる'
      expect(page).not_to have_field 'q[prefecture_eq]'
      expect(page).not_to have_field 'q[city_cont]'
      expect(page).not_to have_field 'q[title_cont]'
      expect(page).not_to have_field 'q[keywords_keyword_cont]'
      expect(page).not_to have_button '検索'
    end
  end

  describe 'スポット一覧画面のテスト' do
    before do
      visit spots_path
    end

    context 'スポット一覧表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/spots'
      end
      it '「スポット一覧」と表示されている' do
        expect(page).to have_content 'スポット一覧'
      end
      it '自分と他人のスポットの画像(1枚目)が表示される：1枚目が1枚ずつ表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      end
      it '自分と他人のスポットのタイトルのリンク先がそれぞれ正しい' do
        expect(page).to have_link spot.title, href: spot_path(spot)
        expect(page).to have_link other_spot.title, href: spot_path(other_spot)
      end
      it '自分と他人のスポットの所在地が表示される' do
        expect(page).to have_content spot.prefecture
        expect(page).to have_content other_spot.prefecture
        expect(page).to have_content spot.city
        expect(page).to have_content other_spot.city
      end
      it '自分と他人のスポットの投稿日が表示される' do
        expect(page).to have_content spot.created_at.strftime("%Y年%-m月%-d日")
        expect(page).to have_content other_spot.created_at.strftime("%Y年%-m月%-d日")
      end
      it '自分と他人のスポットの来訪日が表示される' do
        expect(page).to have_content spot.visited_day.strftime("%Y年%-m月%-d日")
        expect(page).to have_content other_spot.visited_day.strftime("%Y年%-m月%-d日")
      end
      it '自分と他人のスポットの評価が表示される', js: true do
        expect(page).to have_content spot.rate
        expect(page).to have_content other_spot.rate
        sleep 3
      end
      it '自分と他人のスポットのいいねボタンが表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
        expect(page).to have_link '', href: spot_favorites_path(other_spot)
      end
      it '自分と他人のスポットのいいね数が表示される' do
        expect(page).to have_content spot.favorites.count
        expect(page).to have_content other_spot.favorites.count
      end
    end

    context '検索エリアの確認' do
      it '都道府県フォームが表示されている' do
        expect(page).to have_field 'q[prefecture_eq]'
      end
      it '市区町村フォームが表示されている' do
        expect(page).to have_field 'q[city_cont]'
      end
      it 'タイトルフォームが表示されている' do
        expect(page).to have_field 'q[title_cont]'
      end
      it 'キーワードフォームが表示されている' do
        expect(page).to have_field 'q[keywords_keyword_cont]'
      end
      it '検索ボタンが表示される' do
        expect(page).to have_button '検索'
      end
    end
  end

  describe 'スポット新規投稿のテスト' do
    before do
      visit new_spot_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/spots/new'
      end
      it '「新規スポット」と表示される' do
        expect(page).to have_content '新規スポット'
      end
      it '「タイトル」フォームが表示される' do
        expect(page).to have_field 'spot[title]'
      end
      it '「キーワード」フォームが表示される' do
        expect(page).to have_field 'spot[keyword]'
      end
      it '「所在地(都道府県)」フォームが表示される' do
        expect(page).to have_field 'spot[prefecture]'
      end
      it '「所在地(市区町村)」フォームが表示される' do
        expect(page).to have_field 'spot[city]'
      end
      it '「来訪日」フォームが表示される' do
        expect(page).to have_field 'spot[visited_day]'
      end
      it '「評価」フォームが表示される' do
        expect(find('input[@name="spot[rate]"]', visible: false).text).to be_blank
      end
      it '画像選択のフォームが3つ表示される' do
        expect(page).to have_field 'spot[spot_image1]'
        expect(page).to have_field 'spot[spot_image2]'
        expect(page).to have_field 'spot[spot_image3]'
      end
      it '「内容・感想」フォームが表示される' do
        expect(page).to have_field 'spot[content]'
      end
      it '「投稿する」ボタンが表示される' do
        expect(page).to have_button '投稿する'
      end
    end

    context '新規投稿のテスト' do
      before do
        fill_in 'spot[title]', with: Faker::Lorem.characters(number: 10)
        fill_in 'spot[keyword]', with: '東京タワー'
        select '東京都', from: 'spot_prefecture'
        fill_in 'spot[city]', with: Faker::Lorem.characters(number: 10)
        fill_in 'spot[visited_day]', with: '2021-01-01'
        find('input[@name="spot[rate]"]', visible: false).set('5')
        attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
        attach_file "spot[spot_image2]", "app/assets/images/image2.jpg"
        attach_file "spot[spot_image3]", "app/assets/images/image3.jpg"
        fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
      end

      it '正しく新規投稿される' do
        expect { click_button '投稿する' }.to change(Spot.all, :count).by(1)
      end
      it '新規投稿後のリダイレクト先が、新規投稿できたスポットの詳細画面になっている' do
        click_button '投稿する'
        expect(current_path).to eq '/spots/' + Spot.last.id.to_s
      end
      it 'キーワードが表示され、リンク先が正しい' do
        click_button '投稿する'
        expect(page).to have_link '東京タワー', href: keyword_path(Keyword.last.id)
      end
    end
  end

  describe '自分のスポット詳細画面のテスト' do
    before do
      visit spot_path(spot)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/spots/' + spot.id.to_s
      end
      it 'スポットのタイトルが表示される' do
        expect(page).to have_content spot.title
      end
      it 'スポットの所在地が表示される' do
        expect(page).to have_content spot.prefecture
        expect(page).to have_content spot.city
      end
      it 'スポットの投稿日が表示される' do
        expect(page).to have_content spot.created_at.strftime("%Y年%-m月%-d日")
      end
      it 'スポットの来訪日が表示される' do
        expect(page).to have_content spot.visited_day.strftime("%Y年%-m月%-d日")
      end
      it 'スポットの評価が表示される', js: true do
        expect(page).to have_content spot.rate
        sleep 3
      end
      it '自分のスポットのいいねボタン及びいいね数が表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
        expect(page).to have_content spot.favorites.count
      end
      # 'スポットのキーワードが表示される'は、新規登録のテストで確認
      it 'スポットの画像が表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        expect(page).to have_selector("img[src$='spot_image2.jpeg']")
        expect(page).to have_selector("img[src$='spot_image3.jpeg']")
      end
      it 'スポットの内容が表示される' do
        expect(page).to have_content spot.content
      end
      it 'スポットの編集ボタンが表示される' do
        expect(page).to have_link '編集する', href: edit_spot_path(spot)
      end
      it 'スポットの削除ボタンが表示される' do
        expect(page).to have_link '削除する', href: spot_path(spot)
      end
    end

    context 'サイドバーの確認' do
      it '「投稿者プロフィール」と表示されている' do
        expect(page).to have_content '投稿者プロフィール'
      end
      it '自分のプロフィール画像が表示される' do
        expect(page).to have_selector("img[src$='profile_image.jpeg']")
      end
      it '自分のニックネームが表示される' do
        expect(page).to have_content user.nickname
      end
      it '自分の性別が表示される' do
        expect(page).to have_content user.sex
      end
      it '自分の年齢が表示される' do
        expect(page).to have_content user.age
      end
      it '自分の住所が表示される' do
        expect(page).to have_content user.prefecture
        expect(page).to have_content user.city
      end
      it '自分の自己紹介が表示される' do
        expect(page).to have_content user.introduction
      end
      it '「プロフィールをみる」(マイページ画面へのリンク)が表示される' do
        expect(page).to have_link 'プロフィールをみる', href: user_path(user)
      end
    end

    context 'コメントエリアのテスト' do
      it '「コメント」と表示される' do
        expect(page).to have_content 'コメント'
      end
      it 'コメントの全件数が表示される' do
        expect(page).to have_content "全#{spot.comments.count}件"
      end
      it 'コメント入力エリアが表示される' do
        expect(page).to have_content 'コメントをどうぞ'
        expect(page).to have_field 'comment[comment]'
        expect(page).to have_button '送信する'
      end
    end

    context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link '編集する'
        expect(current_path).to eq '/spots/' + spot.id.to_s + '/edit'
      end
    end

    context '削除リンクのテスト' do
      before do
        click_link '削除する'
      end

      it '正しく削除される', js: true do
        expect(Spot.where(id: spot.id).count).to eq 0
      end
      it 'リダイレクト先が、マイページ画面になっている', js: true do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

  describe '自分のスポット編集画面のテスト' do
    before do
      visit edit_spot_path(spot)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/spots/' + spot.id.to_s + '/edit'
      end
      it '「スポット編集」と表示される' do
        expect(page).to have_content 'スポット編集'
      end
      it 'タイトル編集フォームにスポットのタイトルが表示される' do
        expect(page).to have_field 'spot[title]', with: spot.title
      end
      it 'キーワードフォームが表示される' do
        expect(page).to have_field 'spot[keyword]'
      end
      it '都道府県選択フォームでスポットの都道府県が選択されている' do
        expect(page).to have_select('都道府県', selected: '東京都')
      end
      it '市区町村編集フォームにスポットの市区町村が表示される' do
        expect(page).to have_field 'spot[city]', with: spot.city
      end
      it '生年月日編集フォームにスポットの来訪日が表示される' do
        expect(page).to have_field 'spot[visited_day]', with: spot.visited_day
      end
      it '評価フォームが表示される' do
        expect(find('input[@name="spot[rate]"]', visible: false).text).to be_blank
      end
      it '画像選択フォームが3つ表示される' do
        expect(page).to have_field 'spot[spot_image1]'
        expect(page).to have_field 'spot[spot_image2]'
        expect(page).to have_field 'spot[spot_image3]'
      end
      it 'スポットの画像が表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        expect(page).to have_selector("img[src$='spot_image2.jpeg']")
        expect(page).to have_selector("img[src$='spot_image3.jpeg']")
      end
      it '内容・感想編集フォームにスポットの内容・感想が表示される' do
        expect(page).to have_field 'spot[content]', with: spot.content
      end
      it '更新ボタンが表示される' do
        expect(page).to have_button '更新する'
      end
    end

    context '編集成功のテスト' do
      before do
        @spot_old_title = spot.title
        @spot_old_prefecture = spot.prefecture
        @spot_old_city = spot.city
        @spot_old_visited_day = spot.visited_day
        @spot_old_rate = spot.rate
        @spot_old_image1 = spot.spot_image1
        @spot_old_image2 = spot.spot_image2
        @spot_old_image3 = spot.spot_image3
        fill_in 'spot[title]', with: Faker::Lorem.characters(number: 9)
        select '神奈川県', from: 'spot_prefecture'
        fill_in 'spot[city]', with: Faker::Lorem.characters(number: 9)
        fill_in 'spot[visited_day]', with: '2021-01-01'
        find('input[@name="spot[rate]"]', visible: false).set('4')
        attach_file "spot[spot_image1]", "app/assets/images/image4.jpg"
        attach_file "spot[spot_image2]", "app/assets/images/image5.jpg"
        attach_file "spot[spot_image3]", "app/assets/images/image6.jpg"
        fill_in 'spot[content]', with: Faker::Lorem.characters(number: 49)
        click_button '更新する'
      end

      it 'タイトルが正しく更新される' do
        expect(spot.reload.title).not_to eq @spot_old_title
      end
      it '都道府県が正しく更新される' do
        expect(spot.reload.prefecture).not_to eq @spot_old_prefecture
      end
      it '市区町村が正しく更新される' do
        expect(spot.reload.city).not_to eq @spot_old_city
      end
      it '来訪日が正しく更新される' do
        expect(spot.reload.visited_day).not_to eq @spot_old_visited_day
      end
      it '評価が正しく更新される' do
        expect(spot.reload.rate).not_to eq @spot_old_rate
      end
      it '写真(1枚目)が正しく更新される' do
        expect(spot.reload.spot_image1).not_to eq @spot_old_image1
      end
      it '写真(2枚目)が正しく更新される' do
        expect(spot.reload.spot_image2).not_to eq @spot_old_image2
      end
      it '写真(3枚目)が正しく更新される' do
        expect(spot.reload.spot_image3).not_to eq @spot_old_image3
      end
      it 'リダイレクト先が、更新したスポットの詳細画面になっている' do
        expect(current_path).to eq '/spots/' + spot.id.to_s
        expect(page).to have_content "#{spot.reload.title}"
      end
    end
  end

  describe 'ユーザ一覧画面のテスト' do
    before do
      visit users_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users'
      end
      it '自分と他人の画像が表示される' do
        expect(all('img').size).to eq(2)
      end
      it '自分と他人の名前がそれぞれ表示される' do
        expect(page).to have_content user.nickname
        expect(page).to have_content other_user.nickname
      end
      it '自分と他人のユーザー詳細ページへのリンクがそれぞれ表示される' do
        expect(page).to have_link "#{user.nickname}", href: user_path(user)
        expect(page).to have_link "#{other_user.nickname}", href: user_path(other_user)
      end
      it '自分と他人の年齢がそれぞれ表示される' do
        expect(page).to have_content user.nickname
        expect(page).to have_content other_user.nickname
      end
      it '自分と他人の性別がそれぞれ表示される' do
        expect(page).to have_content user.sex
        expect(page).to have_content other_user.sex
      end
      it '自分と他人の住所がそれぞれ表示される' do
        expect(page).to have_content user.prefecture
        expect(page).to have_content user.city
        expect(page).to have_content other_user.prefecture
        expect(page).to have_content other_user.city
      end
      it '自分と他人の自己紹介がそれぞれ表示される' do
        expect(page).to have_content user.introduction
        expect(page).to have_content other_user.introduction
      end
    end

    context '検索エリアの確認' do
      it '都道府県フォームが表示されている' do
        expect(page).to have_field 'q[prefecture_eq]'
      end
      it '市区町村フォームが表示されている' do
        expect(page).to have_field 'q[city_cont]'
      end
      it '性別フォームが表示されている' do
        expect(page).to have_field 'q[sex_eq]'
      end
      it '年齢フォームが表示されている：〜歳以上〜歳以下' do
        expect(page).to have_field 'q[birthday_to_age_gteq]'
        expect(page).to have_field 'q[birthday_to_age_lt]'
      end
      it 'ニックネームフォームが表示されている' do
        expect(page).to have_field 'q[nickname_cont]'
      end
      it '検索ボタンが表示される' do
        expect(page).to have_button '検索'
      end
    end
  end

  describe '自分のユーザ詳細画面のテスト' do
    before do
      visit user_path(user)
    end

    context '表示の確認' do
      it '「マイページ」と表示されている' do
        expect(page).to have_content 'マイページ'
      end
      it '自分のプロフィール画像が表示される' do
        expect(page).to have_selector("img[src$='profile_image.jpeg']")
      end
      it '自分のニックネームが表示される' do
        expect(page).to have_content user.nickname
      end
      it '自分の性別が表示される' do
        expect(page).to have_content user.sex
      end
      it '自分の年齢が表示される' do
        expect(page).to have_content user.age
      end
      it '自分の住所が表示される' do
        expect(page).to have_content user.prefecture
        expect(page).to have_content user.city
      end
      it '自分の自己紹介が表示される' do
        expect(page).to have_content user.introduction
      end
      it '自分のフォロー数が表示される' do
        expect(page).to have_content user.following.count
      end
      it '自分のフォロワー数が表示される' do
        expect(page).to have_content user.followers.count
      end
      it '自分のスポット数が表示される' do
        expect(page).to have_content user.spots.count
      end
      it '自分の総いいね数が表示される' do
        @user = User.first
        @all_user_spots = @user.spots
        @all_user_favorites_count = 0
        @all_user_spots.each do |spot|
          @all_user_favorites_count += spot.favorites.count
        end
        expect(page).to have_content @all_user_favorites_count
      end
      it '「プロフィール編集」のリンクが存在する' do
        expect(page).to have_link 'プロフィール編集', href: edit_user_path(user)
      end
    end

    context 'サイドバーの確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
      it 'スポット一覧に自分のスポットの画像(1枚目)が表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      end
      it 'スポット一覧に自分のスポットのタイトルが表示され、リンクが正しい' do
        expect(page).to have_link spot.title, href: spot_path(spot)
      end
      it 'スポット一覧に自分のスポットの所在地が表示される' do
        expect(page).to have_content spot.prefecture
        expect(page).to have_content spot.city
      end
      it 'スポット一覧に自分のスポットの投稿日が表示される' do
        expect(page).to have_content spot.created_at.strftime("%Y年%-m月%-d日")
      end
      it 'スポット一覧に自分のスポットの来訪日が表示される' do
        expect(page).to have_content spot.visited_day.strftime("%Y年%-m月%-d日")
      end
      it 'スポットの評価が表示される', js: true do
        expect(page).to have_content spot.rate
        sleep 3
      end
      it '自分のスポットのいいねボタンおよびいいね数が表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
        expect(page).to have_content spot.favorites.count
      end
      it '他人のスポットのタイトルは表示されない' do
        expect(page).not_to have_link other_spot.title, href: spot_path(other_spot)
      end
    end
  end

  describe '自分のユーザ情報編集画面のテスト' do
    before do
      visit edit_user_path(user)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s + '/edit'
      end
      it '氏名(フルネーム)編集フォームに自分のフルネームが表示される' do
        expect(page).to have_field 'user[fullname]', with: user.fullname
      end
      it 'ニックネーム編集フォームに自分のニックネームが表示される' do
        expect(page).to have_field 'user[nickname]', with: user.nickname
      end
      it 'メールアドレス編集フォームに自分のメールアドレスが表示される' do
        expect(page).to have_field 'user[email]', with: user.email
      end
      it '性別選択フォームで自分の性別が選択されている' do
        expect(page).to have_checked_field 'edit_user_sex_male'
      end
      it '生年月日編集フォームに自分の生年月日が表示される' do
        expect(page).to have_field 'user[birthday]', with: user.birthday
      end
      it '都道府県選択フォームで自分の都道府県が選択されている' do
        expect(page).to have_select('都道府県', selected: '東京都')
      end
      it '市区町村編集フォームに自分の市区町村が表示される' do
        expect(page).to have_field 'user[city]', with: user.city
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'user[profile_image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it '「更新する」ボタンが表示される' do
        expect(page).to have_button '更新する'
      end
    end

    context '更新成功のテスト' do
      before do
        @user_old_fullname = user.fullname
        @user_old_nickname = user.nickname
        @user_old_email = user.email
        @user_old_sex = user.sex
        @user_old_birthday = user.birthday
        @user_old_prefecture = user.prefecture
        @user_old_city = user.city
        @user_old_profile_image = user.profile_image
        @user_old_introduction = user.introduction
        fill_in 'user[fullname]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[nickname]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[email]', with: Faker::Internet.email
        choose('edit_user_sex_female')
        fill_in 'user[birthday]', with: '2001-01-01'
        select '神奈川県', from: 'user_prefecture'
        fill_in 'user[city]', with: Faker::Lorem.characters(number: 6)
        attach_file "user[profile_image]", "app/assets/images/image8.jpg"
        fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 19)
        click_button '更新する'
      end

      it '氏名(フルネーム)が正しく更新される' do
        expect(user.reload.fullname).not_to eq @user_old_fullname
      end
      it 'ニックネームが正しく更新される' do
        expect(user.reload.nickname).not_to eq @user_old_nickname
      end
      it 'メールアドレスが正しく更新される' do
        expect(user.reload.email).not_to eq @user_old_email
      end
      it '性別が正しく更新される' do
        expect(user.reload.sex).not_to eq @user_old_sex
      end
      it '生年月日が正しく更新される' do
        expect(user.reload.birthday).not_to eq @user_old_birthday
      end
      it 'メールアドレスが正しく更新される' do
        expect(user.reload.email).not_to eq @user_old_email
      end
      it '都道府県が正しく更新される' do
        expect(user.reload.prefecture).not_to eq @user_old_prefecture
      end
      it '市区町村が正しく更新される' do
        expect(user.reload.city).not_to eq @user_old_city
      end
      it 'プロフィール画像が正しく更新される' do
        expect(user.reload.profile_image).not_to eq @user_old_profile_image
      end
      it '自己紹介が正しく更新される' do
        expect(user.reload.introduction).not_to eq @user_old_introduction
      end
      it 'リダイレクト先が、自分のユーザ詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

  describe 'コメント機能のテスト' do
    let!(:other_user2) { create(:user) }
    let!(:other_spot2) { create(:spot, user: other_user2) }
    let!(:comment) { create(:comment, user: user, spot: other_spot2) }
    let!(:other_comment) { create(:comment, user: other_user, spot: other_spot2) }

    before do
      visit spot_path(other_spot2)
    end

    context '表示の確認' do
      it '自分と他人のニックネームのリンクが表示され、リンク先が正しい' do
        expect(page).to have_link user.nickname, href: user_path(user)
        expect(page).to have_link other_user.nickname, href: user_path(other_user)
      end
      it '自分と他人のコメントの内容が表示される' do
        expect(page).to have_content comment.comment
        expect(page).to have_content other_comment.comment
      end
      it '自分と他人のコメントの送信日時が表示される' do
        expect(page).to have_content comment.created_at.strftime("%Y年%-m月%-d日 %-H:%M")
        expect(page).to have_content other_comment.created_at.strftime("%Y年%-m月%-d日 %-H:%M")
      end
      it '自分のコメントの削除リンクが表示される' do
        expect(page).to have_link 'delete-' + comment.id.to_s + '-btn'
      end
      it '他人のコメントの削除リンクは表示されない' do
        expect(page).not_to have_link 'delete-' + other_comment.id.to_s + '-btn'
      end
    end

    context '新規コメント送信のテスト' do
      before do
        fill_in 'comment[comment]', with: Faker::Lorem.characters(number: 50)
      end

      it '正しく送信される', js: true do
        expect { click_button '送信する' }.to change { user.comments.count }.by(1)
      end
      it '遷移先が、スポット詳細になっている', js: true do
        expect(current_path).to eq '/spots/' + other_spot2.id.to_s
      end
    end

    context '削除のテスト' do
      it '正しく削除される', js: true do
        expect { click_link 'delete-' + comment.id.to_s + '-btn' }.to change { user.comments.count }.by(-1)
      end
      it '遷移先が、マイページ画面になっている', js: true do
        expect(current_path).to eq '/spots/' + other_spot2.id.to_s
      end
    end
  end

  describe 'フォロー機能のテスト' do
    context 'フォロー・フォロワー一覧のページのテスト' do
      let!(:other_user2) { create(:user) }

      before do
        user.follow(other_user)
        user.follow(other_user2)
        other_user.follow(user)
      end

      it 'フォロー一覧、「(自分のニックネーム)さんのフォロー一覧」と表示されているか' do
        visit following_user_path(user)
        expect(page).to have_content "#{user.nickname}さんのフォロー一覧"
      end
      it 'フォロー一覧、自分がフォローしているユーザーの情報が表示されているか' do
        visit following_user_path(user)
        expect(page).to have_selector("img[src$='profile_image.jpeg']")
        expect(page).to have_content other_user.nickname
        expect(page).to have_content other_user.following.count
        expect(page).to have_content other_user.followers.count
        expect(page).to have_content other_user.spots.last.updated_at.strftime("%Y年%-m月%-d日")
      end
      it 'フォロワー一覧、「(自分のニックネーム)さんのフォロワー一覧」と表示されているか' do
        visit followers_user_path(user)
        expect(page).to have_content "#{user.nickname}さんのフォロワー一覧"
      end
      it 'フォロワー一覧、自分をフォローしているユーザーの情報が表示されているか' do
        visit followers_user_path(user)
        expect(page).to have_selector("img[src$='profile_image.jpeg']")
        expect(page).to have_content other_user.nickname
        expect(page).to have_content other_user.following.count
        expect(page).to have_content other_user.followers.count
        expect(page).to have_content other_user.spots.last.updated_at.strftime("%Y年%-m月%-d日")
      end
      it '一度も投稿していないユーザーの場合、「投稿なし」が表示されているか' do
        visit following_user_path(user)
        expect(page).to have_content '投稿なし'
      end
    end

    context 'フォロー一覧のページのテスト(追加)' do
      let!(:other_user2) { create(:user) }

      before do
        user.follow(other_user2)
        visit following_user_path(user)
      end

      it '一度も投稿していないユーザーの場合、「投稿なし」が表示されているか' do
        expect(page).to have_content '投稿なし'
      end
    end

    context 'フォロー・フォロー解除のテスト' do
      before do
        visit user_path(other_user)
      end

      it 'フォローする：フォロー数が1となり、ボタンが「フォロー解除」に変化する', js: true do
        click_button 'フォローする'
        expect(other_user.followers.count).to eq 1
        expect(page).to have_button 'フォロー解除'
      end
      it 'フォロー解除する：フォロー数が0となり、ボタンが「フォローする」に変化する', js: true do
        click_button 'フォローする'
        click_button 'フォロー解除'
        expect(other_user.followers.count).to eq 0
        expect(page).to have_button 'フォローする'
      end
    end
  end

  describe '検索機能のテスト' do
    let!(:search_user) { create(:search_user) }
    let!(:search_user2) { create(:search_user2) }
    let!(:search_spot) { create(:search_spot, user: user) }
    let!(:search_spot2) { create(:search_spot2, user: user) }

    context '検索機能のテスト(スポット一覧画面)' do
      # フォームの表示はテスト済
      before do
        visit spots_path
      end

      it '都道府県での検索：条件に合致するものだけが表示されるか' do
        select '千葉県', from: 'q_prefecture_eq'
        click_button '検索'
        expect(page).to have_content 'ディズニーランド'
        expect(page).not_to have_content '稲荷山古墳'
      end
      it '市区町村での検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[city_cont]', with: '行田'
        click_button '検索'
        expect(page).not_to have_content 'ディズニーランド'
        expect(page).to have_content '稲荷山古墳'
      end
      it 'タイトルでの検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[title_cont]', with: 'ディズニー'
        click_button '検索'
        expect(page).to have_content 'ディズニーランド'
        expect(page).not_to have_content '稲荷山古墳'
      end
    end

    context '検索機能のテスト(ユーザー一覧画面)' do
      # フォームの表示はテスト済
      before do
        visit users_path
      end

      it '都道府県での検索：条件に合致するものだけが表示されるか' do
        select '千葉県', from: 'q_prefecture_eq'
        click_button '検索'
        expect(page).to have_content 'ハナコ'
        expect(page).not_to have_content 'タロー'
      end
      it '市区町村での検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[city_cont]', with: '所沢'
        click_button '検索'
        expect(page).not_to have_content 'ハナコ'
        expect(page).to have_content 'タロー'
      end
      it '性別での検索：条件に合致するものだけが表示されるか' do
        choose('q_sex_eq_1') # 女性
        click_button '検索'
        expect(page).to have_content 'ハナコ'
        expect(page).not_to have_content 'タロー'
      end
      it '年齢での検索：検索結果に合致するものだけが表示されるか' do
        fill_in 'q[birthday_to_age_gteq]', with: '30'
        fill_in 'q[birthday_to_age_lt]', with: '40'
        click_button '検索'
        expect(page).to have_content 'ハナコ'
        expect(page).not_to have_content 'タロー'
      end
      it 'ニックネームでの検索：検索結果に合致するものだけが表示されるか' do
        fill_in 'q[nickname_cont]', with: 'タロ'
        click_button '検索'
        expect(page).not_to have_content 'ハナコ'
        expect(page).to have_content 'タロー'
      end
    end

    context '検索機能のテスト(キーワード一覧画面)' do
      before do
        visit edit_spot_path(search_spot)
        fill_in 'spot[keyword]', with: '夢の国 ミッキー'
        click_button '更新する'
        visit edit_spot_path(search_spot2)
        fill_in 'spot[keyword]', with: '前方後円墳 鉄剣'
        click_button '更新する'
        visit keywords_path
      end

      it '都道府県での検索：条件に合致するものだけが表示されるか' do
        select '千葉県', from: 'q_spots_prefecture_eq'
        click_button '検索'
        expect(page).to have_content '夢の国'
        expect(page).to have_content 'ミッキー'
        expect(page).not_to have_content '前方後円墳'
        expect(page).not_to have_content '鉄剣'
      end
      it '市区町村での検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[spots_city_cont]', with: '行田'
        click_button '検索'
        expect(page).not_to have_content '夢の国'
        expect(page).not_to have_content 'ミッキー'
        expect(page).to have_content '前方後円墳'
        expect(page).to have_content '鉄剣'
      end
      it 'キーワードでの検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[keyword_cont]', with: '円'
        click_button '検索'
        expect(page).not_to have_content '夢の国'
        expect(page).not_to have_content 'ミッキー'
        expect(page).to have_content '前方後円墳'
        expect(page).not_to have_content '鉄剣'
      end
    end
  end
end

describe '[STEP2] ユーザログイン後のテスト ソート機能のテスト' do
  let(:search_user) { create(:search_user) }
  let!(:search_user2) { create(:search_user2) }
  let!(:search_spot) { create(:search_spot, user: search_user) }
  let!(:search_spot2) { create(:search_spot2, user: search_user) }
  let!(:favorite) { create(:favorite, user: search_user, spot: search_spot) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: search_user.email
    fill_in 'user[password]', with: search_user.password
    click_button 'ログイン'
  end

  context 'ソート機能のテスト(ユーザー詳細画面)' do
    before do
      visit user_path(search_user)
    end

    it 'タイトルのソート：正しく表示されるか' do
      click_link 'タイトル' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link 'タイトル' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '所在地のソート：正しく表示されるか' do
      click_link '所在地' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link '所在地' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
    it '投稿日のソート：正しく表示されるか' do
      click_link '投稿日' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link '投稿日' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '来訪日のソート：正しく表示されるか' do
      click_link '来訪日' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link '来訪日' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '評価のソート：正しく表示されるか' do
      click_link '評価' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link '評価' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
    it 'いいねのソート：正しく表示されるか' do
      click_link 'いいね' # 昇順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link 'いいね' # 降順
      first_spot_link = find_all('a')[19].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
  end

  context 'ソート機能のテスト(スポット一覧画面)' do
    before do
      visit spots_path
    end

    it 'タイトルのソート：正しく表示されるか' do
      click_link 'タイトル' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link 'タイトル' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '所在地のソート：正しく表示されるか' do
      click_link '所在地' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link '所在地' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
    it '投稿日のソート：正しく表示されるか' do
      click_link '投稿日' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link '投稿日' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '来訪日のソート：正しく表示されるか' do
      click_link '来訪日' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
      click_link '来訪日' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
    end
    it '評価のソート：正しく表示されるか' do
      click_link '評価' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link '評価' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
    it 'いいねのソート：正しく表示されるか' do
      click_link 'いいね' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('稲荷山古墳')
      click_link 'いいね' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランド')
    end
  end

  context 'ソート機能のテスト(ユーザー一覧画面)' do
    before do
      visit users_path
    end

    it '年齢のソート：正しく表示されるか' do
      click_link '年齢' # 昇順
      first_spot_link = find_all('a')[11].native.inner_text
      expect(first_spot_link).to match('ハナコ')
      click_link '年齢' # 降順
      first_spot_link = find_all('a')[11].native.inner_text
      expect(first_spot_link).to match('タロー')
    end
  end

  context 'ソート機能のテスト(キーワード一覧・詳細画面)' do
    before do
      visit new_spot_path
      fill_in 'spot[title]', with: 'ディズニーランドから見た東京タワー'
      fill_in 'spot[keyword]', with: '東京タワー'
      select '千葉県', from: 'spot_prefecture'
      fill_in 'spot[city]', with: '浦安市'
      fill_in 'spot[visited_day]', with: '2021-02-01'
      find('input[@name="spot[rate]"]', visible: false).set('4')
      attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
      fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
      click_button '投稿する'
      visit new_spot_path
      fill_in 'spot[title]', with: '夜の東京タワー'
      fill_in 'spot[keyword]', with: '東京タワー'
      select '東京都', from: 'spot_prefecture'
      fill_in 'spot[city]', with: '港区'
      fill_in 'spot[visited_day]', with: '2021-01-01'
      find('input[@name="spot[rate]"]', visible: false).set('5')
      attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
      fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
      click_button '投稿する'
      visit new_spot_path
      fill_in 'spot[title]', with: 'あべのハルカス'
      fill_in 'spot[keyword]', with: 'あべのハルカス'
      select '大阪府', from: 'spot_prefecture'
      fill_in 'spot[city]', with: '大阪市阿倍野区'
      fill_in 'spot[visited_day]', with: '2020-01-01'
      find('input[@name="spot[rate]"]', visible: false).set('4')
      attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
      fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
      click_button '投稿する'
    end

    let!(:favorite2) { create(:favorite, user: search_user, spot: Spot.find(3)) }

    it 'キーワード一覧画面：各項目が表示されている' do
      visit keywords_path
      expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      expect(page).to have_link '東京タワー', href: keyword_path(Keyword.first.id)
      expect(page).to have_link 'あべのハルカス', href: keyword_path(Keyword.last.id)
      expect(page).to have_content Keyword.first.spots.count
      expect(page).to have_content Keyword.first.spots.average(:rate)
      expect(page).to have_content Keyword.last.spots.count
      expect(page).to have_content Keyword.last.spots.average(:rate)
    end
    it 'キーワード一覧画面：キーワード評価平均のソートが正しく表示されるか' do
      visit keywords_path
      click_link '評価平均' # 昇順
      first_spot_link = find_all('a')[11].native.inner_text
      expect(first_spot_link).to match('あべのハルカス')
      click_link '評価平均' # 降順
      first_spot_link = find_all('a')[11].native.inner_text
      expect(first_spot_link).to match('東京タワー')
    end
    it 'キーワード詳細画面：各項目が表示されている' do
      visit keyword_path(Keyword.first)
      expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      expect(page).to have_link 'ディズニーランドから見た東京タワー', href: spot_path(Spot.find(3))
      expect(page).to have_link '夜の東京タワー', href: spot_path(Spot.find(4))
      expect(page).to have_content Spot.find(3).prefecture
      expect(page).to have_content Spot.find(4).prefecture
      expect(page).to have_content Spot.find(3).city
      expect(page).to have_content Spot.find(4).city
      expect(page).to have_content Spot.find(3).created_at.strftime("%Y年%-m月%-d日")
      expect(page).to have_content Spot.find(4).created_at.strftime("%Y年%-m月%-d日")
      expect(page).to have_content Spot.find(3).visited_day.strftime("%Y年%-m月%-d日")
      expect(page).to have_content Spot.find(4).visited_day.strftime("%Y年%-m月%-d日")
      expect(page).to have_link '', href: spot_favorites_path(Spot.find(3))
      expect(page).to have_link '', href: spot_favorites_path(Spot.find(4))
      expect(page).to have_content Spot.find(3).favorites.count
      expect(page).to have_content Spot.find(4).favorites.count
    end
    it 'キーワード詳細画面：タイトルのソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link 'タイトル' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
      click_link 'タイトル' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
    end
    it 'キーワード詳細画面：所在地のソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link '所在地' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
      click_link '所在地' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
    end
    it 'キーワード詳細画面：投稿日のソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link '投稿日' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
      click_link '投稿日' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
    end
    it 'キーワード詳細画面：来訪日のソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link '来訪日' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
      click_link '来訪日' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
    end
    it 'キーワード詳細画面：評価のソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link '評価' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
      click_link '評価' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
    end
    it 'キーワード詳細画面：評価のソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link '評価' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
      click_link '評価' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
    end
    it 'キーワード詳細画面：いいねのソートが正しく表示されるか' do
      visit keyword_path(Keyword.first)
      click_link 'いいね' # 昇順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('夜の東京タワー')
      click_link 'いいね' # 降順
      first_spot_link = find_all('a')[16].native.inner_text
      expect(first_spot_link).to match('ディズニーランドから見た東京タワー')
    end
  end
end

describe '[STEP2] ユーザログイン後のテスト いいね機能のテスト' do
  let(:user) { create(:user) }
  let!(:spot) { create(:spot, user: user) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
  end

  context 'トップ画面でのテスト' do
    before do
      visit top_path
    end

    it 'いいねを押す', js: true do
      expect do
        find("#like-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect do
        find("#unlike-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end

  context 'ユーザー詳細画面でのテスト' do
    before do
      visit user_path(user)
    end

    it 'いいねを押す', js: true do
      expect do
        find("#like-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect do
        find("#unlike-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end

  context 'スポット詳細画面でのテスト' do
    before do
      visit spot_path(spot)
    end

    it 'いいねを押す', js: true do
      expect do
        find("#like-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect do
        find("#unlike-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end

  context 'スポット一覧画面でのテスト' do
    before do
      visit spots_path
    end

    it 'いいねを押す', js: true do
      expect do
        find("#like-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect do
        find("#unlike-#{spot.id}").click
        sleep 1
      end.to change { spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end
  # キーワード詳細でのいいね機能はそれぞれのテスト内で実施済
end

describe '[STEP2] ユーザログイン後のテスト ランキング(スポットいいね数)のテスト' do
  let!(:user) { create(:user, profile_image: nil) }
  let!(:spot1) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot2) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot3) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot4) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot5) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:favorite1) { create(:favorite, user: user, spot: spot1) }
  let!(:favorite2) { create(:favorite, user: user, spot: spot2) }
  let!(:favorite3) { create(:favorite, user: user, spot: spot3) }
  let!(:favorite4) { create(:favorite, user: user, spot: spot4) }
  let!(:favorite5) { create(:favorite, user: user, spot: spot5) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'
    visit spot_favorite_ranking_path
  end

  context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が5以下の場合' do
    it '「現在準備中です。」と表示される' do
      expect(page).to have_content '現在準備中です。'
    end
    it '「こちら」がいいね数ランキング(ユーザー)へのリンクとなっている' do
      expect(page).to have_link 'こちら', href: user_favorite_ranking_path
    end
  end

  context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が6以上10以下の場合' do
    let!(:spot6) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot7) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:favorite6) { create(:favorite, user: user, spot: spot6) }

    it '順位が表示される' do
      expect(page).to have_content '第1位'
    end
    it 'スポットのタイトルが表示される' do
      expect(page).to have_content spot1.title
    end
    it 'スポットの所在地が表示される' do
      expect(page).to have_content spot1.prefecture
      expect(page).to have_content spot1.city
    end
    it 'スポットの投稿日が表示される' do
      expect(page).to have_content spot1.created_at.strftime("%Y年%-m月%-d日")
    end
    it 'スポットの投稿者のニックネームが表示される' do
      expect(page).to have_content spot1.user.nickname
    end
    it 'スポットのいいね数が表示される' do
      expect(page).to have_content spot1.favorites.count
    end
    it 'いいね数0のスポットは表示されない' do
      expect(page).not_to have_content spot7.title
    end
  end

  context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が11以上の場合' do
    let!(:spot6) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot7) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot8) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot9) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot10) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot11) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:favorite6) { create(:favorite, user: user, spot: spot6) }
    let!(:favorite7) { create(:favorite, user: user, spot: spot7) }
    let!(:favorite8) { create(:favorite, user: user, spot: spot8) }
    let!(:favorite9) { create(:favorite, user: user, spot: spot9) }
    let!(:favorite10) { create(:favorite, user: user, spot: spot10) }
    let!(:favorite11) { create(:favorite, user: user, spot: spot11) }
    let!(:favorite12) { create(:favorite, user: user, spot: spot1) }
    let!(:favorite13) { create(:favorite, user: user, spot: spot2) }
    let!(:favorite14) { create(:favorite, user: user, spot: spot3) }
    let!(:favorite15) { create(:favorite, user: user, spot: spot4) }
    let!(:favorite16) { create(:favorite, user: user, spot: spot5) }
    let!(:favorite17) { create(:favorite, user: user, spot: spot6) }
    let!(:favorite18) { create(:favorite, user: user, spot: spot7) }
    let!(:favorite19) { create(:favorite, user: user, spot: spot8) }
    let!(:favorite20) { create(:favorite, user: user, spot: spot9) }
    let!(:favorite21) { create(:favorite, user: user, spot: spot10) }

    it '順位が表示される' do
      expect(page).to have_content '第1位'
    end
    it 'スポットのタイトルが表示される' do
      expect(page).to have_content spot1.title
    end
    it 'スポットの所在地が表示される' do
      expect(page).to have_content spot1.prefecture
      expect(page).to have_content spot1.city
    end
    it 'スポットの投稿日が表示される' do
      expect(page).to have_content spot1.created_at.strftime("%Y年%-m月%-d日")
    end
    it 'スポットの投稿者のニックネームが表示される' do
      expect(page).to have_content spot1.user.nickname
    end
    it 'スポットのいいね数が表示される' do
      expect(page).to have_content spot1.favorites.count
    end
    # it '第11位は表示されない' do
    # expect(page).not_to have_content '第11位'
    # end
  end
end

describe '[STEP2] ユーザログイン後のテスト ランキング(ユーザーいいね数)のテスト' do
  let!(:user1) { create(:user, profile_image: nil) }
  let!(:user2) { create(:user, profile_image: nil) }
  let!(:user3) { create(:user, profile_image: nil) }
  let!(:user4) { create(:user, profile_image: nil) }
  let!(:user5) { create(:user, profile_image: nil) }
  let!(:spot1) { create(:spot, user: user1, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot2) { create(:spot, user: user2, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot3) { create(:spot, user: user3, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot4) { create(:spot, user: user4, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:spot5) { create(:spot, user: user5, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
  let!(:favorite1) { create(:favorite, user: user1, spot: spot1) }
  let!(:favorite2) { create(:favorite, user: user2, spot: spot2) }
  let!(:favorite3) { create(:favorite, user: user3, spot: spot3) }
  let!(:favorite4) { create(:favorite, user: user4, spot: spot4) }
  let!(:favorite5) { create(:favorite, user: user5, spot: spot5) }

  before do
    visit new_user_session_path
    fill_in 'user[email]', with: user1.email
    fill_in 'user[password]', with: user1.password
    click_button 'ログイン'
    visit user_favorite_ranking_path
  end

  context 'いいね数ランキング(スポット)、総いいね数1以上のユーザー数が5以下の場合' do
    it '「現在準備中です。」と表示される' do
      expect(page).to have_content '現在準備中です。'
    end
    it '「こちら」がいいね数ランキング(スポット)へのリンクとなっている' do
      expect(page).to have_link 'こちら', href: spot_favorite_ranking_path
    end
  end

  context 'いいね数ランキング(スポット)、総いいね数1以上のユーザー数が6以上10以下の場合' do
    let!(:user6) { create(:user, profile_image: nil) }
    let!(:user7) { create(:user, profile_image: nil) }
    let!(:spot6) { create(:spot, user: user6, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot7) { create(:spot, user: user7, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:favorite6) { create(:favorite, user: user6, spot: spot6) }

    it '順位が表示される' do
      expect(page).to have_content '第1位'
    end
    it 'ユーザーのニックネームが表示される' do
      expect(page).to have_content user1.title
    end
    it 'ユーザーの住所が表示される' do
      expect(page).to have_content user1.prefecture
      expect(page).to have_content user1.city
    end
    it 'ユーザーの年齢が表示される' do
      expect(page).to have_content user1.age
    end
    it 'ユーザーの投稿スポット数が表示される' do
      expect(page).to have_content user1.spots.count
    end
    it 'ユーザーの獲得総いいね数が表示される' do
      user = User.find(1)
      all_user_spots = user.spots
      all_user_favorites_count = 0
      all_user_spots.each do |spot|
        all_user_favorites_count += spot.favorites.count
      end
      expect(page).to have_content all_user_favorites_count
    end
    it 'いいね数0のユーザーは表示されない' do
      expect(page).not_to have_content user7.nickname
    end
  end

  context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が11以上の場合' do
    let!(:user6) { create(:user, profile_image: nil) }
    let!(:user7) { create(:user, profile_image: nil) }
    let!(:user8) { create(:user, profile_image: nil) }
    let!(:user9) { create(:user, profile_image: nil) }
    let!(:user10) { create(:user, profile_image: nil) }
    let!(:user11) { create(:user, profile_image: nil) }
    let!(:spot6) { create(:spot, user: user6, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot7) { create(:spot, user: user7, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot8) { create(:spot, user: user8, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot9) { create(:spot, user: user9, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot10) { create(:spot, user: user10, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:spot11) { create(:spot, user: user11, spot_image1: nil, spot_image2: nil, spot_image3: nil) }
    let!(:favorite6) { create(:favorite, user: user6, spot: spot6) }
    let!(:favorite7) { create(:favorite, user: user7, spot: spot7) }
    let!(:favorite8) { create(:favorite, user: user8, spot: spot8) }
    let!(:favorite9) { create(:favorite, user: user9, spot: spot9) }
    let!(:favorite10) { create(:favorite, user: user10, spot: spot10) }
    let!(:favorite11) { create(:favorite, user: user11, spot: spot11) }
    let!(:favorite12) { create(:favorite, user: user1, spot: spot1) }
    let!(:favorite13) { create(:favorite, user: user2, spot: spot2) }
    let!(:favorite14) { create(:favorite, user: user3, spot: spot3) }
    let!(:favorite15) { create(:favorite, user: user4, spot: spot4) }
    let!(:favorite16) { create(:favorite, user: user5, spot: spot5) }
    let!(:favorite17) { create(:favorite, user: user6, spot: spot6) }
    let!(:favorite18) { create(:favorite, user: user7, spot: spot7) }
    let!(:favorite19) { create(:favorite, user: user8, spot: spot8) }
    let!(:favorite20) { create(:favorite, user: user9, spot: spot9) }
    let!(:favorite21) { create(:favorite, user: user10, spot: spot10) }

    it '順位が表示される' do
      byebug
      expect(page).to have_content '第1位'
    end
    it 'ユーザーのニックネームが表示される' do
      expect(page).to have_content user1.title
    end
    it 'ユーザーの住所が表示される' do
      expect(page).to have_content user1.prefecture
      expect(page).to have_content user1.city
    end
    it 'ユーザーの年齢が表示される' do
      expect(page).to have_content user1.age
    end
    it 'ユーザーの投稿スポット数が表示される' do
      expect(page).to have_content user1.spots.count
    end
    it 'ユーザーの獲得総いいね数が表示される' do
      user = User.find(1)
      all_user_spots = user.spots
      all_user_favorites_count = 0
      all_user_spots.each do |spot|
        all_user_favorites_count += spot.favorites.count
      end
      expect(page).to have_content all_user_favorites_count
    end
    # it '第11位は表示されない' do
    # expect(page).not_to have_content '第11位'
    # end
  end
end
