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
      #fill_in 'spot[rate]', with: '5', visible: false
      #写真(1〜3枚目)の入力


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
        #expect(page).to have_field 'user[profile_image]', with: user.profile_image
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
        #fill_in 'spot[rate]', with: '5', visible: false
        #写真(1〜3枚目)の入力


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
        #写真1〜3枚目
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
        #写真1〜3枚目
        expect(page).to have_field 'spot[content]', with: spot.content
      end
      it 'エラーメッセージが表示される' do
        expect(page).to have_content 'タイトルを入力してください'
      end
    end
  end

  describe 'ログインしていない場合のアクセス制限のテスト: アクセスできず、ログイン画面に遷移する' do
    subject { current_path }

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it 'ユーザ情報編集画面' do
      visit edit_user_path(user)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿一覧画面' do
      visit books_path
      is_expected.to eq '/users/sign_in'
    end
    it '投稿詳細画面' do
      visit book_path(book)
      is_expected.to eq '/users/sign_in'
    end
    it '投稿編集画面' do
      visit edit_book_path(book)
      is_expected.to eq '/users/sign_in'
    end
  end

  describe '他人の画面のテスト' do
    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
    end

    describe '他人の投稿詳細画面のテスト' do
      before do
        visit book_path(other_book)
      end

      context '表示内容の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/books/' + other_book.id.to_s
        end
        it '「Book detail」と表示される' do
          expect(page).to have_content 'Book detail'
        end
        it 'ユーザ画像・名前のリンク先が正しい' do
          expect(page).to have_link other_book.user.name, href: user_path(other_book.user)
        end
        it '投稿のtitleが表示される' do
          expect(page).to have_content other_book.title
        end
        it '投稿のopinionが表示される' do
          expect(page).to have_content other_book.body
        end
        it '投稿の編集リンクが表示されない' do
          expect(page).not_to have_link 'Edit'
        end
        it '投稿の削除リンクが表示されない' do
          expect(page).not_to have_link 'Destroy'
        end
      end

      context 'サイドバーの確認' do
        it '他人の名前と紹介文が表示される' do
          expect(page).to have_content other_user.name
          expect(page).to have_content other_user.introduction
        end
        it '他人のユーザ編集画面へのリンクが存在する' do
          expect(page).to have_link '', href: edit_user_path(other_user)
        end
        it '自分の名前と紹介文は表示されない' do
          expect(page).not_to have_content user.name
          expect(page).not_to have_content user.introduction
        end
        it '自分のユーザ編集画面へのリンクは存在しない' do
          expect(page).not_to have_link '', href: edit_user_path(user)
        end
      end
    end

    context '他人の投稿編集画面' do
      it '遷移できず、投稿一覧画面にリダイレクトされる' do
        visit edit_book_path(other_book)
        expect(current_path).to eq '/books'
      end
    end

    describe '他人のユーザ詳細画面のテスト' do
      before do
        visit user_path(other_user)
      end

      context '表示の確認' do
        it 'URLが正しい' do
          expect(current_path).to eq '/users/' + other_user.id.to_s
        end
        it '投稿一覧のユーザ画像のリンク先が正しい' do
          expect(page).to have_link '', href: user_path(other_user)
        end
        it '投稿一覧に他人の投稿のtitleが表示され、リンクが正しい' do
          expect(page).to have_link other_book.title, href: book_path(other_book)
        end
        it '投稿一覧に他人の投稿のopinionが表示される' do
          expect(page).to have_content other_book.body
        end
        it '自分の投稿は表示されない' do
          expect(page).not_to have_content book.title
          expect(page).not_to have_content book.body
        end
      end

      context 'サイドバーの確認' do
        it '他人の名前と紹介文が表示される' do
          expect(page).to have_content other_user.name
          expect(page).to have_content other_user.introduction
        end
        it '他人のユーザ編集画面へのリンクが存在する' do
          expect(page).to have_link '', href: edit_user_path(other_user)
        end
        it '自分の名前と紹介文は表示されない' do
          expect(page).not_to have_content user.name
          expect(page).not_to have_content user.introduction
        end
        it '自分のユーザ編集画面へのリンクは存在しない' do
          expect(page).not_to have_link '', href: edit_user_path(user)
        end
      end
    end

    context '他人のユーザ情報編集画面' do
      it '遷移できず、自分のユーザ詳細画面にリダイレクトされる' do
        visit edit_user_path(other_user)
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end
  end

  describe 'グリッドシステムのテスト: container, row, col-md-〇を正しく使えている' do
    subject { page }

    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
    end

    it 'ユーザ一覧画面' do
      visit users_path
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it 'ユーザ詳細画面' do
      visit user_path(user)
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it '投稿一覧画面' do
      visit books_path
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
    it '投稿詳細画面' do
      visit book_path(book)
      is_expected.to have_selector '.container .row .col-md-3'
      is_expected.to have_selector '.container .row .col-md-8.offset-md-1'
    end
  end

  describe 'アイコンのテスト' do
    context 'トップ画面' do
      subject { page }

      before do
        visit root_path
      end

      it '本のアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-book'
      end
    end

    context 'アバウト画面' do
      subject { page }

      before do
        visit '/home/about'
      end

      it '本のアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-book'
      end
    end

    context 'ヘッダー: ログインしていない場合' do
      subject { page }

      before do
        visit root_path
      end

      it 'Homeリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-home'
      end
      it 'Aboutリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-link'
      end
      it 'sign upリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-user-plus'
      end
      it 'loginリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-sign-in-alt'
      end
    end

    context 'ヘッダー: ログインしている場合' do
      subject { page }

      before do
        visit new_user_session_path
        fill_in 'user[name]', with: user.name
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'Homeリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-home'
      end
      it 'Usersリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-users'
      end
      it 'Booksリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-book-open'
      end
      it 'log outリンクのアイコンが表示される' do
        is_expected.to have_selector '.fas.fa-sign-out-alt'
      end
    end

    context 'サイドバー' do
      subject { page }

      before do
        visit new_user_session_path
        fill_in 'user[name]', with: user.name
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'ユーザ一覧画面でレンチアイコンが表示される' do
        visit users_path
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it 'ユーザ詳細画面でレンチアイコンが表示される' do
        visit user_path(user)
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it '投稿一覧画面でレンチアイコンが表示される' do
        visit books_path
        is_expected.to have_selector '.fas.fa-user-cog'
      end
      it '投稿詳細画面でレンチアイコンが表示される' do
        visit book_path(book)
        is_expected.to have_selector '.fas.fa-user-cog'
      end
    end
  end
end
