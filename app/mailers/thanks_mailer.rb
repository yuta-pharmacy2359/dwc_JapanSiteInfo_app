class ThanksMailer < ApplicationMailer
  def complete_registration(user)
    @user = user
    mail(:subject => "新規登録完了のお知らせ", to: user.email)
  end
end