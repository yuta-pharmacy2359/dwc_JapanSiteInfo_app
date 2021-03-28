class CustomAuthenticationFailure < Devise::FailureApp
  protected

  def redirect_url
    new_user_registration_path
  end
end
