require 'sendgrid-ruby'
include SendGrid

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # requires the following environment variables:
  # CLIENT_URL
  # MAIL_FROM_EMAIL
  # MAIL_PASSWORD_RESET_SUBJECT (optional)
  # SENDGRID_API_KEY
  def send_password_reset_email
    from = SendGrid::Email.new(email: ENV.fetch("MAIL_FROM_EMAIL"))
    to = SendGrid::Email.new(email: self.email)

    body = "#{ENV.fetch('CLIENT_URL')}/password_reset?token=#{generate_reset_token}"

    subject = ENV.fetch("MAIL_PASSWORD_RESET_SUBJECT", 'Password Reset')
    content = SendGrid::Content.new(type: 'text/html', value: body)
    mail = SendGrid::Mail.new(from, subject, to, content)
  
    sg = SendGrid::API.new(api_key: ENV.fetch('SENDGRID_API_KEY'))
    response = sg.client.mail._('send').post(request_body: mail.to_json)
  end

  private

  def generate_reset_token
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed
    self.reset_password_sent_at = Time.now.utc
    self.save
    raw
  end

end
