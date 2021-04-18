class ThanksMailer < ApplicationMailer
  def complete_registration(user)
    @user = user
    if user.present?
      mail(:subject => "新規登録完了のお知らせ", to: user.email)
    end
  end
end