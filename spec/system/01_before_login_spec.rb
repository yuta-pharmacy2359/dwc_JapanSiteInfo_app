require 'rails_helper'

describe '[STEP1] ユーザログイン前のテスト' do
  describe 'トップ画面のテスト' do
    let(:user) { create(:user) }
    let!(:search_spot) { create(:search_spot, user: user) }
    let!(:search_spot2) { create(:search_spot2, user: user) }
    let!(:favorite) { create(:favorite, user: nil, spot: search_spot) }
    let!(:favorite2) { create(:favorite, user: nil, spot: search_spot) }
    let!(:favorite3) { create(:favorite, user: nil, spot: search_spot2) }

    before do
      visit top_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/'
      end
      it '新規登録リンクが表示される: 左上から3番目のリンクが「新規登録」である' do
        sign_up_link = find_all('a')[2].native.inner_text
        expect(sign_up_link).to match('新規登録')
      end
      it '新規登録リンクの内容が正しい' do
        sign_up_link = find_all('a')[2]
        sign_up_link.click
        expect(current_path).to eq('/users/sign_up')
      end
      it 'ログインリンクが表示される: 左上から4番目のリンクが「ログイン」である' do
        log_in_link = find_all('a')[3].native.inner_text
        expect(log_in_link).to match('ログイン')
      end
      it 'ログインリンクの内容が正しい' do
        log_in_link = find_all('a')[3]
        log_in_link.click
        expect(current_path).to eq('/users/sign_in')
      end
    end

    context '新着スポット画面のテスト' do
      it '「新着スポット」と表示されている' do
        expect(page).to have_content '新着スポット'
      end
      it 'スポットの画像(1枚目)が表示されている' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
      end
      it '各スポットのタイトルが表示され、リンク先がそれぞれ正しい' do
        expect(page).to have_link search_spot.title, href: spot_path(search_spot)
        expect(page).to have_link search_spot2.title, href: spot_path(search_spot2)
      end
      it '各スポットの所在地が表示される' do
        expect(page).to have_content search_spot.prefecture
        expect(page).to have_content search_spot2.prefecture
        expect(page).to have_content search_spot.city
        expect(page).to have_content search_spot2.city
      end
      it '各スポットの投稿日が表示される' do
        expect(page).to have_content search_spot.created_at.strftime("%Y年%-m月%-d日")
        expect(page).to have_content search_spot2.created_at.strftime("%Y年%-m月%-d日")
      end
      it '各スポットの来訪日が表示される' do
        expect(page).to have_content search_spot.visited_day.strftime("%Y年%-m月%-d日")
        expect(page).to have_content search_spot2.visited_day.strftime("%Y年%-m月%-d日")
      end
      it '各スポットの評価が表示される', js: true do
        expect(page).to have_content search_spot.rate
        expect(page).to have_content search_spot2.rate
        sleep 3
      end
      it '各スポットのいいねボタンが表示される' do
        expect(page).to have_link '', href: spot_favorites_path(search_spot)
        expect(page).to have_link '', href: spot_favorites_path(search_spot2)
      end
      it '各スポットのいいね数が表示される' do
        expect(page).to have_content search_spot.favorites.count
        expect(page).to have_content search_spot2.favorites.count
      end
    end

    context 'スポット検索のテスト(キーワード以外)' do
      it '「スポットを探してみる」と表示されている' do
        expect(page).to have_content 'スポットを探してみる'
      end
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

    context 'スポット検索のテスト(キーワード)' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit edit_spot_path(search_spot)
        fill_in 'spot[keyword]', with: '夢の国 ミッキー'
        click_button '更新する'
        visit edit_spot_path(search_spot2)
        fill_in 'spot[keyword]', with: '稲荷山公園 前方後円墳'
        click_button '更新する'
        click_link 'ログアウト'
      end

      it 'タイトルでの検索：条件に合致するものだけが表示されるか' do
        fill_in 'q[keywords_keyword_cont]', with: 'ミッキー'
        click_button '検索'
        expect(page).to have_content 'ディズニーランド'
        expect(page).not_to have_content '稲荷山古墳'
      end
    end

    context 'ソート機能のテスト(スポット一覧画面)' do
      before do
        click_button '検索'
      end

      it 'タイトルのソート：正しく表示されるか' do
        click_link 'タイトル' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
        click_link 'タイトル' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it '所在地のソート：正しく表示されるか' do
        click_link '所在地' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
        click_link '所在地' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
      end
      it '投稿日のソート：正しく表示されるか' do
        click_link '投稿日' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
        click_link '投稿日' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it '来訪日のソート：正しく表示されるか' do
        click_link '来訪日' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
        click_link '来訪日' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it '評価のソート：正しく表示されるか' do
        click_link '評価' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
        click_link '評価' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
      end
      it 'いいねのソート：正しく表示されるか' do
        click_link 'いいね' #昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
        click_link 'いいね' #降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('ディズニーランド')
      end
    end
  end

  describe 'スポット詳細画面のテスト' do
    let(:user) { create(:user) }
    let!(:spot) { create(:spot, user: user) }
    let!(:comment) { create(:comment, user: user, spot: spot) }

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
      it 'スポットのいいねボタンといいね数が表示される' do
        expect(page).to have_link '', href: spot_favorites_path(spot)
        expect(page).to have_content spot.favorites.count
      end
      it 'スポットの画像が表示される' do
        expect(page).to have_selector("img[src$='spot_image1.jpeg']")
        expect(page).to have_selector("img[src$='spot_image2.jpeg']")
        expect(page).to have_selector("img[src$='spot_image3.jpeg']")
      end
      it 'スポットの内容が表示される' do
        expect(page).to have_content spot.content
      end
      it 'スポットの編集ボタンは表示されない' do
        expect(page).not_to have_link '編集する', href: edit_spot_path(spot)
      end
      it 'スポットの削除ボタンは表示されない' do
        expect(page).not_to have_link '削除する', href: spot_path(spot)
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
      it '「プロフィールをみる」(ユーザー詳細画面へのリンク)は表示されない' do
        expect(page).not_to have_link 'プロフィールをみる', href: user_path(user)
      end
    end

    context 'コメントエリアのテスト' do
      it '「コメント」と表示される' do
        expect(page).to have_content 'コメント'
      end
      it 'コメントの全件数が表示される' do
        expect(page).to have_content "全#{spot.comments.count}件"
      end
      it 'コメントしたユーザーのニックネームが表示される(リンクではない)' do
        expect(page).to have_content user.nickname
        expect(page).not_to have_link user.nickname, href: user_path(user)
      end
      it 'コメントの内容が表示される' do
        expect(page).to have_content comment.comment
      end
      it 'コメントの送信日時が表示される' do
        expect(page).to have_content comment.created_at.strftime("%Y年%-m月%-d日 %-H:%M")
      end
      it 'コメントの削除リンクは表示されない' do
        expect(page).not_to have_link 'delete-' + comment.id.to_s + '-btn'
      end
      it 'コメント入力エリアは表示されない' do
        expect(page).not_to have_content 'コメントをどうぞ'
        expect(page).not_to have_field 'comment[comment]'
        expect(page).not_to have_button '送信する'
      end
    end

    context 'キーワード関連のテスト' do
      before do
        visit new_user_session_path
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
        visit edit_spot_path(spot)
        fill_in 'spot[keyword]', with: '東京駅 丸の内'
        find('input[@name="spot[rate]"]', visible: false).set('5')
        click_button '更新する'
        click_link 'ログアウト'
      end

      it 'スポット詳細画面、キーワードが表示され、リンク先が正しい' do
        visit spot_path(spot)
        expect(page).to have_link '東京駅', href: keyword_path(Keyword.first)
        expect(page).to have_link '丸の内', href: keyword_path(Keyword.last)
      end
    end
  end

  describe 'キーワード詳細画面のテスト' do
    let(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:spot) { create(:search_spot2, user: user) }
    let!(:other_spot) { create(:search_spot3, user: user) }
    let!(:favorite1) { create(:favorite, user: user, spot: spot) }
    let!(:favorite2) { create(:favorite, user: user, spot: other_spot) }
    let!(:favorite3) { create(:favorite, user: other_user, spot: spot) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      visit edit_spot_path(spot)
      fill_in 'spot[keyword]', with: '前方後円墳'
      find('input[@name="spot[rate]"]', visible: false).set('4')
      click_button '更新する'
      visit edit_spot_path(other_spot)
      fill_in 'spot[keyword]', with: '前方後円墳'
      find('input[@name="spot[rate]"]', visible: false).set('3')
      click_button '更新する'
      click_link 'ログアウト'
      visit keyword_path(Keyword.first)
    end

    context '表示の確認' do
      it '「キーワード：「キーワード名」 スポット一覧」と表示される' do
        expect(page).to have_content "キーワード：「#{Keyword.first.keyword}」 スポット一覧"
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
      # 他のところで確認
      it '各スポットの評価が表示される', js: true do
        expect(page).to have_content spot.rate
        expect(page).to have_content other_spot.rate
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

    context 'ソート機能のテスト(キーワード詳細画面)' do
      it 'タイトルのソート：正しく表示されるか' do
        click_link 'タイトル' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
        click_link 'タイトル' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it '所在地のソート：正しく表示されるか' do
        click_link '所在地' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
        click_link '所在地' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
      end
      it '投稿日のソート：正しく表示されるか' do
        click_link '投稿日' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
        click_link '投稿日' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
      end
      it '来訪日のソート：正しく表示されるか' do
        click_link '来訪日' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
        click_link '来訪日' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it '評価のソート：正しく表示されるか' do
        click_link '評価' # 昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
        click_link '評価' # 降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
      it 'いいねのソート：正しく表示されるか' do
        click_link 'いいね' #昇順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('大仙陵古墳')
        click_link 'いいね' #降順
        first_spot_link = find_all('a')[10].native.inner_text
        expect(first_spot_link).to match('稲荷山古墳')
      end
    end
  end

  describe 'アバウト画面のテスト' do
    before do
      visit '/about'
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/about'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしていない場合' do
    before do
      visit top_path
    end

    context '表示内容の確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'JapanSiteInfo'
      end
      it 'アバウトリンクが表示される: 左上から2番目のリンクが「JSIとは？」である' do
        about_link = find_all('a')[1].native.inner_text
        expect(about_link).to match('JSIとは？')
      end
      it '新規登録リンクが表示される: 左上から3番目のリンクが「新規登録」である' do
        signup_link = find_all('a')[2].native.inner_text
        expect(signup_link).to match('新規登録')
      end
      it 'ログインリンクが表示される: 左上から4番目のリンクが「ログイン」である' do
        login_link = find_all('a')[3].native.inner_text
        expect(login_link).to match('ログイン')
      end
    end

    context 'リンクの内容を確認' do
      subject { current_path }

      it '「JapanSiteInfo」を押すと、トップ画面に遷移する' do
        home_link = find_all('a')[0].native.inner_text
        home_link = home_link.delete(' ')
        home_link.gsub!(/\n/, '')
        click_link home_link
        is_expected.to eq '/'
      end
      it '「JSIとは？」を押すと、アバウト画面に遷移する' do
        about_link = find_all('a')[1].native.inner_text
        about_link = about_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link about_link
        is_expected.to eq '/about'
      end
      it '「新規登録」を押すと、新規登録画面に遷移する' do
        signup_link = find_all('a')[2].native.inner_text
        signup_link = signup_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link signup_link
        is_expected.to eq '/users/sign_up'
      end
      it '「ログイン」を押すと、ログイン画面に遷移する' do
        login_link = find_all('a')[3].native.inner_text
        login_link = login_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link login_link
        is_expected.to eq '/users/sign_in'
      end
    end
  end

  describe 'ユーザ新規登録のテスト' do
    before do
      visit new_user_registration_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_up'
      end
      it '「新規会員登録」と表示される' do
        expect(page).to have_content '新規会員登録'
      end
      it '「氏名(フルネーム)」フォームが表示される' do
        expect(page).to have_field 'user[fullname]'
      end
      it '「ニックネーム」フォームが表示される' do
        expect(page).to have_field 'user[nickname]'
      end
      it '「メールアドレス」フォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it '「性別」フォームが表示される' do
        expect(page).to have_field 'user[sex]'
      end
      it '「誕生日」フォームが表示される' do
        expect(page).to have_field 'user[birthday]'
      end
      it '「住所(都道府県)」フォームが表示される' do
        expect(page).to have_field 'user[prefecture]'
      end
      it '「住所(市区町村)」フォームが表示される' do
        expect(page).to have_field 'user[city]'
      end
      it '「パスワード(英数字6文字以上)」フォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it '「パスワード（確認）」フォームが表示される' do
        expect(page).to have_field 'user[password_confirmation]'
      end
      it '新規登録ボタンが表示される' do
        expect(page).to have_button '新規登録'
      end
      it '「会員の方はこちらからログイン」と表示されている' do
        expect(page).to have_content '会員の方はこちらからログイン'
      end
      it '「こちら」を押すとログイン画面に遷移する' do
        log_in_link = find_all('a')[4]
        log_in_link.click
        expect(current_path).to eq('/users/sign_in')
      end
    end

    context '新規登録成功のテスト' do
      before do
        fill_in 'user[fullname]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[nickname]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: Faker::Internet.email
        choose('user_sex_male')
        fill_in 'user[birthday]', with: '2000-01-01'
        select '東京都', from: 'user_prefecture'
        fill_in 'user[city]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button '新規登録' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できたユーザの詳細画面になっている' do
        click_button '新規登録'
        expect(current_path).to eq '/users/' + User.last.id.to_s
      end
    end
  end

  describe 'ユーザログイン' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/sign_in'
      end
      it '「ログイン」と表示される' do
        expect(page).to have_content 'ログイン'
      end
      it '「メールアドレス」フォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it '「パスワード」フォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it '「ログイン」ボタンが表示される' do
        expect(page).to have_button 'ログイン'
      end
      it '「入力情報を記憶する」のチェックボックスが表示されている' do
        expect(page).to have_field('user_remember_me')
      end
      it '「新規登録はこちらから」と表示されている' do
        expect(page).to have_content '新規登録はこちらから'
      end
      it '「こちら(新規登録)」を押すと新規登録画面に遷移する' do
        log_in_link = find_all('a')[4]
        log_in_link.click
        expect(current_path).to eq('/users/sign_up')
      end
      it '「パスワードをお忘れの方はこちら」と表示されている' do
        expect(page).to have_content 'パスワードをお忘れの方はこちら'
      end
      it '「こちら(パスワード)」を押すとパスワード発行画面に遷移する' do
        log_in_link = find_all('a')[5]
        log_in_link.click
        expect(current_path).to eq('/users/password/new')
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'user[email]', with: user.email
        fill_in 'user[password]', with: user.password
        click_button 'ログイン'
      end

      it 'ログイン後のリダイレクト先が、ログインしたユーザの詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end

    context 'ログイン失敗のテスト' do
      before do
        fill_in 'user[email]', with: ''
        fill_in 'user[password]', with: ''
        click_button 'ログイン'
      end

      it 'ログインに失敗し、ログイン画面にリダイレクトされる' do
        expect(current_path).to eq '/users/sign_in'
      end
    end
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
    end

    context 'ヘッダーの表示を確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'JapanSiteInfo'
      end
      it 'ユーザー名が表示される: 左上から2番目のリンクが「(ユーザーニックネーム)さん」である' do
        users_link = find_all('a')[1].native.inner_text
        expect(users_link).to match("#{user.nickname}さん")
      end
      it '「マイページ」リンクが表示される: 左上から3番目のリンクが「マイページ」である' do
        books_link = find_all('a')[2].native.inner_text
        expect(books_link).to match('マイページ')
      end
      it '「新規投稿」リンクが表示される: 左上から4番目のリンクが「新規投稿」である' do
        books_link = find_all('a')[3].native.inner_text
        expect(books_link).to match('新規投稿')
      end
      it '「一覧・その他」リンクが表示される: 左上から5番目のリンクが「一覧・その他」である' do
        logout_link = find_all('a')[4].native.inner_text
        expect(logout_link).to match('一覧・その他')
      end
      it '「スポット一覧」リンクが表示される: 「一覧・その他」中の1番目のリンクが「スポット一覧」である' do
        logout_link = find_all('a')[5].native.inner_text
        expect(logout_link).to match('スポット一覧')
      end
      it '「キーワード一覧」リンクが表示される: 「一覧・その他」中の2番目のリンクが「キーワード一覧」である' do
        logout_link = find_all('a')[6].native.inner_text
        expect(logout_link).to match('キーワード一覧')
      end
      it '「ユーザー一覧」リンクが表示される: 「一覧・その他」中の3番目のリンクが「ユーザー一覧」である' do
        logout_link = find_all('a')[7].native.inner_text
        expect(logout_link).to match('ユーザー一覧')
      end
      it '「ランキング」リンクが表示される: 「一覧・その他」中の4番目のリンクが「ランキング」である' do
        logout_link = find_all('a')[8].native.inner_text
        expect(logout_link).to match('ランキング')
      end
      it '「ログアウト」リンクが表示される: 左上から6番目のリンクが「ログアウト」である' do
        logout_link = find_all('a')[9].native.inner_text
        expect(logout_link).to match('ログアウト')
      end
    end
  end

  describe 'ユーザログアウトのテスト' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      logout_link = find_all('a')[9].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
    end

    context 'ログアウト機能のテスト' do
      it '正しくログアウトできている: ログアウト後のリダイレクト先においてアバウト画面へのリンクが存在する' do
        expect(page).to have_link '', href: '/about'
      end
      it 'ログアウト後のリダイレクト先が、トップになっている' do
        expect(current_path).to eq '/'
      end
    end
  end
end

#describe '[STEP1] ユーザログイン前のテスト いいね機能のテスト' do
  #let(:user) { create(:user, profile_image: nil) }
  #let!(:spot) { create(:spot, user: user, spot_image1: nil, spot_image2: nil, spot_image3: nil) }

  #context 'トップ画面でのテスト' do
    #before do
      #visit top_path
    #end

    #it 'いいねを押す', js: true do
      #expect do
        #find("#like-#{spot.id}").click
        #sleep 1
      #end.to change { spot.favorites.count }.by(1)
      #expect(page).to have_css "#unlike-#{spot.id}"
    #end
  #end

  #context 'ユーザー詳細画面でのテスト' do
    #before do
      #visit user_path(user)
   # end

    #it 'いいねを押す', js: true do
      #expect do
        #find("#like-#{spot.id}").click
        #sleep 1
      #end.to change { spot.favorites.count }.by(1)
      #expect(page).to have_css "#unlike-#{spot.id}"
    #end
  #end

  #context 'スポット詳細画面でのテスト' do
    #before do
      #visit spot_path(spot)
    #end

    #it 'いいねを押す', js: true do
      #expect do
        #find("#like-#{spot.id}").click
        #sleep 1
      #end.to change { spot.favorites.count }.by(1)
      #expect(page).to have_css "#unlike-#{spot.id}"
    #end
  #end

  #context 'スポット一覧画面でのテスト' do
    #before do
      #visit spots_path
    #end

    #it 'いいねを押す', js: true do
      #expect do
        #find("#like-#{spot.id}").click
        #sleep 1
      #end.to change { spot.favorites.count }.by(1)
      #expect(page).to have_css "#unlike-#{spot.id}"
    #end
  #end
#end
