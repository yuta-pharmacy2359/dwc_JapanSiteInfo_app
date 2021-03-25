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
      it '「都道府県」フォームがラベルを含め表示されている' do
        expect(page).to have_content '都道府県'
        expect(page).to have_field 'q[prefecture_eq]'
      end
      it '「市区町村」フォームがラベルを含め表示されている' do
        expect(page).to have_content '市区町村'
        expect(page).to have_field 'q[city_cont]'
      end
      it '「タイトル」フォームがラベルを含め表示されている' do
        expect(page).to have_content 'タイトル'
        expect(page).to have_field 'q[title_cont]'
      end
      it '「キーワード」フォームがラベルを含め表示されている' do
        expect(page).to have_content 'キーワード'
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

    context '新規投稿・キーワードのテスト' do
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
      it 'キーワードが入力されている' do
        click_button '投稿する'
        expect(page).to have_content '東京タワー'
      end
      it 'キーワードのリンク先がキーワード詳細になっている' do
        click_button '投稿する'
        expect(page).to have_link '東京タワー', href: keyword_path(Keyword.last.id)
      end
    end

    context 'キーワード一覧・検索のテスト' do
      before do
        fill_in 'spot[title]', with: Faker::Lorem.characters(number: 10)
        fill_in 'spot[keyword]', with: '東京タワー'
        select '東京都', from: 'spot_prefecture'
        fill_in 'spot[city]', with: '港区'
        fill_in 'spot[visited_day]', with: '2021-01-01'
        find('input[@name="spot[rate]"]', visible: false).set('5')
        attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
        attach_file "spot[spot_image2]", "app/assets/images/image2.jpg"
        attach_file "spot[spot_image3]", "app/assets/images/image3.jpg"
        fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
        click_button '投稿する'
        visit new_spot_path
        fill_in 'spot[title]', with: Faker::Lorem.characters(number: 10)
        fill_in 'spot[keyword]', with: 'あべのハルカス'
        select '大阪府', from: 'spot_prefecture'
        fill_in 'spot[city]', with: '大阪市阿倍野区'
        fill_in 'spot[visited_day]', with: '2020-01-01'
        find('input[@name="spot[rate]"]', visible: false).set('4')
        attach_file "spot[spot_image1]", "app/assets/images/image1.jpg"
        attach_file "spot[spot_image2]", "app/assets/images/image2.jpg"
        attach_file "spot[spot_image3]", "app/assets/images/image3.jpg"
        fill_in 'spot[content]', with: Faker::Lorem.characters(number: 50)
        click_button '投稿する'
        visit keywords_path
      end

      it 'キーワード一覧が表示されている' do
        visit keywords_path
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        expect(page).to have_link '東京タワー', href: keyword_path(Keyword.first.id)
        expect(page).to have_link 'あべのハルカス', href: keyword_path(Keyword.last.id)
        expect(page).to have_content Keyword.first.spots.count
        expect(page).to have_content Keyword.first.spots.average(:rate)
        expect(page).to have_content Keyword.last.spots.count
        expect(page).to have_content Keyword.last.spots.average(:rate)
      end
      it '都道府県での検索：条件に合致するものだけが表示されるか' do
        select '東京都', from: 'q_spots_prefecture_eq'
        click_button '検索'
        expect(page).to have_content '東京タワー'
        expect(page).not_to have_content 'あべのハルカス'
      end
      it '市区町村での検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[spots_city_cont]', with: '阿倍'
        click_button '検索'
        expect(page).not_to have_content '東京タワー'
        expect(page).to have_content 'あべのハルカス'
      end
      it 'キーワードでの検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[keyword_cont]', with: 'タワー'
        click_button '検索'
        expect(page).to have_content '東京タワー'
        expect(page).not_to have_content 'あべのハルカス'
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
      it 'スポットの都道府県が表示される' do
        expect(page).to have_content spot.prefecture
      end
      it 'スポットの市区町村が表示される' do
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
      it '自分のスポットのいいねボタンが表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
      end
      it '自分のスポットのいいね数が表示される' do
        expect(page).to have_content spot.favorites.count
      end
      #'スポットのキーワードが表示される'は、新規登録のテストで確認

      it 'スポットの画像(1枚目)が表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      end
      it 'スポットの画像(2枚目)が表示される' do
        expect(page).to have_selector("img[src$='spot_image2.jpeg']")
      end
      it 'スポットの画像(3枚目)が表示される' do
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
      it '「プロフィールをみる」(マイページ画面へのリンク)が存在する' do
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
      it '「コメントをどうぞ」と表示される' do
        expect(page).to have_content 'コメントをどうぞ'
      end
      it 'コメントフォームが表示される' do
        expect(page).to have_field 'comment[comment]'
      end
      it 'コメント送信ボタンが表示される' do
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
      it '自分と他人のフォロー数がそれぞれ表示される' do
        expect(page).to have_content user.following.count
        expect(page).to have_content other_user.following.count
      end
      it '自分と他人のフォロワー数がそれぞれ表示される' do
        expect(page).to have_content user.followers.count
        expect(page).to have_content other_user.followers.count
      end
      it '自分と他人のスポット数がそれぞれ表示される' do
        expect(page).to have_content user.spots.count
        expect(page).to have_content other_user.spots.count
      end
    end

    context '検索エリアの確認' do
      it '「都道府県」フォームがラベルを含め表示されている' do
        expect(page).to have_content '都道府県'
        expect(page).to have_field 'q[prefecture_eq]'
      end
      it '「市区町村」フォームがラベルを含め表示されている' do
        expect(page).to have_content '市区町村'
        expect(page).to have_field 'q[city_cont]'
      end
      it '「性別」フォームがラベルを含め表示されている' do
        expect(page).to have_content '性別'
        expect(page).to have_field 'q[sex_eq]'
      end
      it '「年齢」フォームがラベルを含め表示されている：〜歳以上〜歳以下' do
        expect(page).to have_content '年齢'
        expect(page).to have_field 'q[birthday_to_age_gteq]'
        expect(page).to have_field 'q[birthday_to_age_lt]'
      end
      it '「ニックネーム」フォームがラベルを含め表示されている' do
        expect(page).to have_content 'キーワード'
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
      it '自分のフォロー数がそれぞれ表示される' do
        expect(page).to have_content user.following.count
      end
      it '自分のフォロワー数がそれぞれ表示される' do
        expect(page).to have_content user.followers.count
      end
      it '自分のスポット数がそれぞれ表示される' do
        expect(page).to have_content user.spots.count
      end
      #it '自分の総いいね数が表示される' do
        #expect(page).to have_content user.all_user_favorites_count
      #end
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
      it '自分のスポットのいいねボタンが表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
      end
      it '自分のスポットのいいね数が表示される' do
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
        expect { click_button '送信する' }.to change{ user.comments.count }.by(1)
      end
      it '遷移先が、スポット詳細になっている', js: true do
        expect(current_path).to eq '/spots/' + other_spot2.id.to_s
      end
    end

    context '削除のテスト' do
      it '正しく削除される', js: true do
        expect { click_link 'delete-' + comment.id.to_s + '-btn' }.to change{ user.comments.count }.by(-1)
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

    context 'スポット一覧画面での検索テスト' do
      #フォームの表示はテスト済
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

    context 'ユーザー一覧画面での検索テスト' do
      #フォームの表示はテスト済
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
        choose('q_sex_eq_1')
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
  end

  describe 'ランキング(スポットいいね数)のテスト' do
    let!(:other_spot2) { create(:spot, user: user) }
    let!(:other_spot3) { create(:spot, user: user) }
    let!(:other_spot4) { create(:spot, user: user) }
    let!(:favorite1) { create(:favorite, spot: spot)}
    let!(:favorite2) { create(:favorite, spot: other_spot)}
    let!(:favorite3) { create(:favorite, spot: other_spot2)}
    let!(:favorite4) { create(:favorite, spot: other_spot3)}
    let!(:favorite5) { create(:favorite, spot: other_spot4)}

    before do
      visit spot_favorite_ranking_path
    end

    context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が5以下の場合' do
      it '「現在準備中です。」と表示される' do
        expect(page).to have_content '現在準備中です。'
      end
      it '「ユーザーのいいね数ランキングは こちら」と表示される' do
        expect(page).to have_content 'ユーザーのいいね数ランキングは こちら'
      end
      it '「こちら」がいいね数ランキング(ユーザー)へのリンクとなっている' do
        expect(page).to have_link 'こちら', href: user_favorite_ranking_path
      end
    end

    context 'いいね数ランキング(スポット)、いいね数1以上のスポット数が11以上の場合' do
      let!(:other_spot5) { create(:spot, user: user) }
      let!(:other_spot6) { create(:spot, user: user) }
      let!(:other_spot7) { create(:spot, user: user) }
      let!(:other_spot8) { create(:spot, user: user) }
      let!(:other_spot9) { create(:spot, user: user) }
      let!(:other_spot10) { create(:spot, user: user) }
      let!(:favorite6) { create(:favorite, spot: other_spot5)}
      let!(:favorite7) { create(:favorite, spot: other_spot6)}
      let!(:favorite8) { create(:favorite, spot: other_spot7)}
      let!(:favorite9) { create(:favorite, spot: other_spot8)}
      let!(:favorite10) { create(:favorite, spot: other_spot9)}
      let!(:favorite11) { create(:favorite, spot: other_spot10)}
      let!(:favorite12) { create(:favorite, spot: spot)}
      let!(:favorite13) { create(:favorite, spot: other_spot)}
      let!(:favorite14) { create(:favorite, spot: other_spot2)}
      let!(:favorite15) { create(:favorite, spot: other_spot3)}
      let!(:favorite16) { create(:favorite, spot: other_spot4)}
      let!(:favorite17) { create(:favorite, spot: other_spot5)}
      let!(:favorite18) { create(:favorite, spot: other_spot6)}
      let!(:favorite19) { create(:favorite, spot: other_spot7)}
      let!(:favorite20) { create(:favorite, spot: other_spot8)}
      let!(:favorite21) { create(:favorite, spot: other_spot9)}

      it '順位が表示される' do
        expect(page).to have_content '第1位'
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
      it 'スポットの投稿者のニックネームが表示される' do
        expect(page).to have_content spot.user.nickname
      end
      it 'スポットのいいね数が表示される' do
        expect(page).to have_content spot.favorites.count
      end
      it '第11位は表示されない' do
        expect(page).not_to have_content '第11位'
      end
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
      expect {
        find("#like-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect {
        find("#unlike-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end
  context 'ユーザー詳細画面でのテスト' do
    before do
      visit user_path(user)
    end
    it 'いいねを押す', js: true do
      expect {
        find("#like-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect {
        find("#unlike-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end
  context 'スポット詳細画面でのテスト' do
    before do
      visit spot_path(spot)
    end
    it 'いいねを押す', js: true do
      expect {
        find("#like-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect {
        find("#unlike-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end
  context 'スポット一覧画面でのテスト' do
    before do
      visit spots_path
    end
    it 'いいねを押す', js: true do
      expect {
        find("#like-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(1)
      expect(page).to have_css "#unlike-#{spot.id}"
    end
    it 'いいねを取り消す', js: true do
      find("#like-#{spot.id}").click
      sleep 1
      expect {
        find("#unlike-#{spot.id}").click
        sleep 1
      }.to change{ spot.favorites.count }.by(-1)
      expect(page).to have_css "#like-#{spot.id}"
    end
  end
  #キーワード詳細でのいいね機能はそれぞれのテスト内で実施済
end