require 'rails_helper'

describe '[STEP2] ユーザログイン後のテスト' do
  let(:user) { create(:user) }
  let(:keyword) { create(:keyword) }
  let!(:other_user) { create(:user) }
  let!(:spot) { create(:spot, user: user) }
  let!(:other_spot) { create(:spot, user: other_user) }

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
      end
      #it 'スポットのキーワードが表示される' do
        #expect(page).to have_css(".keyword", keyword: keyword.keyword)
      #end
      #it 'キーワードのリンク先が正しい' do
        #expect(page).to have_link keyword.keyword, href: keyword_path(keyword)
      #end
      it 'スポットの画像(1枚目)が表示される' do
        expect(page).to have_content spot.spot_image1
      end
      it 'スポットの画像(2枚目)が表示される' do
        expect(page).to have_content spot.spot_image2
      end
      it 'スポットの画像(3枚目)が表示される' do
        expect(page).to have_content spot.spot_image3
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
        expect(page).to have_content user.profile_image
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

    context '投稿成功のテスト' do
      before do
        fill_in 'book[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button 'Create Book' }.to change(user.books, :count).by(1)
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

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_book_path(book)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/books/' + book.id.to_s + '/edit'
      end
      it '「Editing Book」と表示される' do
        expect(page).to have_content 'Editing Book'
      end
      it 'title編集フォームが表示される' do
        expect(page).to have_field 'book[title]', with: book.title
      end
      it 'opinion編集フォームが表示される' do
        expect(page).to have_field 'book[body]', with: book.body
      end
      it 'Update Bookボタンが表示される' do
        expect(page).to have_button 'Update Book'
      end
      it 'Showリンクが表示される' do
        expect(page).to have_link 'Show', href: book_path(book)
      end
      it 'Backリンクが表示される' do
        expect(page).to have_link 'Back', href: books_path
      end
    end

    context '編集成功のテスト' do
      before do
        @book_old_title = book.title
        @book_old_body = book.body
        fill_in 'book[title]', with: Faker::Lorem.characters(number: 4)
        fill_in 'book[body]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update Book'
      end

      it 'titleが正しく更新される' do
        expect(book.reload.title).not_to eq @book_old_title
      end
      it 'bodyが正しく更新される' do
        expect(book.reload.body).not_to eq @book_old_body
      end
      it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/books/' + book.id.to_s
        expect(page).to have_content 'Book detail'
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
      it '自分と他人の画像が表示される: fallbackの画像がサイドバーの1つ＋一覧(2人)の2つの計3つ存在する' do
        expect(all('img').size).to eq(3)
      end
      it '自分と他人の名前がそれぞれ表示される' do
        expect(page).to have_content user.name
        expect(page).to have_content other_user.name
      end
      it '自分と他人のshowリンクがそれぞれ表示される' do
        expect(page).to have_link 'Show', href: user_path(user)
        expect(page).to have_link 'Show', href: user_path(other_user)
      end
    end

    context 'サイドバーの確認' do
      it '自分の名前と紹介文が表示される' do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it '自分のユーザ編集画面へのリンクが存在する' do
        expect(page).to have_link '', href: edit_user_path(user)
      end
      it '「New book」と表示される' do
        expect(page).to have_content 'New book'
      end
      it 'titleフォームが表示される' do
        expect(page).to have_field 'book[title]'
      end
      it 'titleフォームに値が入っていない' do
        expect(find_field('book[title]').text).to be_blank
      end
      it 'opinionフォームが表示される' do
        expect(page).to have_field 'book[body]'
      end
      it 'opinionフォームに値が入っていない' do
        expect(find_field('book[body]').text).to be_blank
      end
      it 'Create Bookボタンが表示される' do
        expect(page).to have_button 'Create Book'
      end
    end
  end

  describe '自分のユーザ詳細画面のテスト' do
    before do
      visit user_path(user)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
      it '投稿一覧のユーザ画像のリンク先が正しい' do
        expect(page).to have_link '', href: user_path(user)
      end
      it '投稿一覧に自分の投稿のtitleが表示され、リンクが正しい' do
        expect(page).to have_link book.title, href: book_path(book)
      end
      it '投稿一覧に自分の投稿のopinionが表示される' do
        expect(page).to have_content book.body
      end
      it '他人の投稿は表示されない' do
        expect(page).not_to have_link '', href: user_path(other_user)
        expect(page).not_to have_content other_book.title
        expect(page).not_to have_content other_book.body
      end
    end

    context 'サイドバーの確認' do
      it '自分の名前と紹介文が表示される' do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it '自分のユーザ編集画面へのリンクが存在する' do
        expect(page).to have_link '', href: edit_user_path(user)
      end
      it '「New book」と表示される' do
        expect(page).to have_content 'New book'
      end
      it 'titleフォームが表示される' do
        expect(page).to have_field 'book[title]'
      end
      it 'titleフォームに値が入っていない' do
        expect(find_field('book[title]').text).to be_blank
      end
      it 'opinionフォームが表示される' do
        expect(page).to have_field 'book[body]'
      end
      it 'opinionフォームに値が入っていない' do
        expect(find_field('book[body]').text).to be_blank
      end
      it 'Create Bookボタンが表示される' do
        expect(page).to have_button 'Create Book'
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
      it '名前編集フォームに自分の名前が表示される' do
        expect(page).to have_field 'user[name]', with: user.name
      end
      it '画像編集フォームが表示される' do
        expect(page).to have_field 'user[profile_image]'
      end
      it '自己紹介編集フォームに自分の自己紹介文が表示される' do
        expect(page).to have_field 'user[introduction]', with: user.introduction
      end
      it 'Update Userボタンが表示される' do
        expect(page).to have_button 'Update User'
      end
    end

    context '更新成功のテスト' do
      before do
        @user_old_name = user.name
        @user_old_intrpduction = user.introduction
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 9)
        fill_in 'user[introduction]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update User'
      end

      it 'nameが正しく更新される' do
        expect(user.reload.name).not_to eq @user_old_name
      end
      it 'introductionが正しく更新される' do
        expect(user.reload.introduction).not_to eq @user_old_intrpduction
      end
      it 'リダイレクト先が、自分のユーザ詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end
end
