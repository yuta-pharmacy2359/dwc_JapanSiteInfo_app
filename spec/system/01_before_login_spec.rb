require 'rails_helper'

describe '[STEP1] ユーザログイン前のテスト' do
  describe 'トップ画面のテスト' do
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
      it 'fullnameフォームが表示される' do
        expect(page).to have_field 'user[fullname]'
      end
      it 'nicknameフォームが表示される' do
        expect(page).to have_field 'user[nickname]'
      end
      it 'emailフォームが表示される' do
        expect(page).to have_field 'user[email]'
      end
      it 'sexフォームが表示される' do
        expect(page).to have_field 'user[sex]'
      end
      it 'birthdayフォームが表示される' do
        expect(page).to have_field 'user[birthday]'
      end
      it 'prefectureフォームが表示される' do
        expect(page).to have_field 'user[prefecture]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'password_confirmationフォームが表示される' do
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
        fill_in 'user[name]', with: Faker::Lorem.characters(number: 10)
        fill_in 'user[email]', with: Faker::Internet.email
        fill_in 'user[password]', with: 'password'
        fill_in 'user[password_confirmation]', with: 'password'
      end

      it '正しく新規登録される' do
        expect { click_button 'Sign up' }.to change(User.all, :count).by(1)
      end
      it '新規登録後のリダイレクト先が、新規登録できたユーザの詳細画面になっている' do
        click_button 'Sign up'
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
      it '「Log in」と表示される' do
        expect(page).to have_content 'Log in'
      end
      it 'nameフォームが表示される' do
        expect(page).to have_field 'user[name]'
      end
      it 'passwordフォームが表示される' do
        expect(page).to have_field 'user[password]'
      end
      it 'Sign upボタンが表示される' do
        expect(page).to have_button 'Log in'
      end
      it 'emailフォームは表示されない' do
        expect(page).not_to have_field 'user[email]'
      end
    end

    context 'ログイン成功のテスト' do
      before do
        fill_in 'user[name]', with: user.name
        fill_in 'user[password]', with: user.password
        click_button 'Log in'
      end

      it 'ログイン後のリダイレクト先が、ログインしたユーザの詳細画面になっている' do
        expect(current_path).to eq '/users/' + user.id.to_s
      end
    end

    context 'ログイン失敗のテスト' do
      before do
        fill_in 'user[name]', with: ''
        fill_in 'user[password]', with: ''
        click_button 'Log in'
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
      fill_in 'user[name]', with: user.name
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
    end

    context 'ヘッダーの表示を確認' do
      it 'タイトルが表示される' do
        expect(page).to have_content 'Bookers'
      end
      it 'Homeリンクが表示される: 左上から1番目のリンクが「Home」である' do
        home_link = find_all('a')[1].native.inner_text
        expect(home_link).to match(/home/i)
      end
      it 'Usersリンクが表示される: 左上から2番目のリンクが「Users」である' do
        users_link = find_all('a')[2].native.inner_text
        expect(users_link).to match(/users/i)
      end
      it 'Booksリンクが表示される: 左上から3番目のリンクが「Books」である' do
        books_link = find_all('a')[3].native.inner_text
        expect(books_link).to match(/books/i)
      end
      it 'log outリンクが表示される: 左上から4番目のリンクが「logout」である' do
        logout_link = find_all('a')[4].native.inner_text
        expect(logout_link).to match(/logout/i)
      end
    end
  end

  describe 'ユーザログアウトのテスト' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
      fill_in 'user[name]', with: user.name
      fill_in 'user[password]', with: user.password
      click_button 'Log in'
      logout_link = find_all('a')[4].native.inner_text
      logout_link = logout_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
      click_link logout_link
    end

    context 'ログアウト機能のテスト' do
      it '正しくログアウトできている: ログアウト後のリダイレクト先においてAbout画面へのリンクが存在する' do
        expect(page).to have_link '', href: '/home/about'
      end
      it 'ログアウト後のリダイレクト先が、トップになっている' do
        expect(current_path).to eq '/'
      end
    end
  end
end
