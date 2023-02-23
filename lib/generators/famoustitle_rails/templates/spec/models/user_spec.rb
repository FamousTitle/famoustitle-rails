require "rails_helper"

describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe '#send_password_reset_email' do
    it 'calls UserNotifierMailer with the reset_url' do
      allow_any_instance_of(User).to receive(:generate_reset_token).and_return('token')
      reset_url = "#{ENV['CLIENT_URL']}/password_reset?token=token"
      stub = double(deliver: true)

      expect(UserNotifierMailer).to receive(:send_password_reset_email)
                                      .with(user, reset_url)
                                      .and_return(stub)
      expect(stub).to receive(:deliver)
      
      user.send_password_reset_email
    end
  end

  describe '.generate_reset_token' do
    it 'saves new values to user' do
      allow_any_instance_of(Devise::TokenGenerator).to receive(:generate).and_return(["123", "456"])
      raw = user.send(:generate_reset_token)
      expect(user.reset_password_token).to eq("456")
      expect(user.reset_password_sent_at).to_not eq(nil)
      expect(raw).to eq("123")
    end
  end

end
