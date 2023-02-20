class UserNotifierMailer < ApplicationMailer
  default :from => ENV['MAIL_FROM_EMAIL']

  def send_password_reset_email(user, reset_url)
    @user = user
    @reset_url = reset_url
    mail(
      to: @user.email,
      subject: 'Password Reset'
    )
  end

end
