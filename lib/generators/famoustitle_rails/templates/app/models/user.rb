class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  def send_password_reset_email
    reset_url = "#{ENV.fetch('CLIENT_URL')}/password_reset?token=#{generate_reset_token}"
    UserNotifierMailer.send_password_reset_email(self, reset_url).deliver
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
