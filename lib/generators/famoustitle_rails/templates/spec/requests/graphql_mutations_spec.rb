require "rails_helper"

describe 'GraphqlMutations', type: :request do

  describe 'POST /graphql' do
    describe 'sendPasswordResetToken' do
      let(:params) {
        {
          query: <<-HEREDOC
            mutation {
              sendPasswordResetToken(email: "some@email.com")
            }
          HEREDOC
        }
      }

      context 'email not found' do
        before do
          allow(User).to receive(:find_by).and_return(nil)
        end

        it 'does not call send_password_reset_email' do
          expect_any_instance_of(User).to_not receive(:send_password_reset_email)
          
          post '/graphql', params: params
            
        end

        it 'responds with ok' do
          post '/graphql', params: params
        json_body = JSON.parse(response.body)
        expect(json_body.dig('data', 'sendPasswordResetToken')).to eq('ok')
        end
      end

      context 'email found' do
        let!(:user) { FactoryBot.create(:user) }

        before do
          allow(User).to receive(:find_by).and_return(user)
        end

        it 'does call send_password_reset_email' do
          expect_any_instance_of(User).to receive(:send_password_reset_email)
          
          post '/graphql', params: params
        end

        it 'responds with ok' do
          allow(UserNotifierMailer).to receive(:send_password_reset_email).and_return(double(deliver: true))
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'sendPasswordResetToken')).to eq('ok')
        end
      end

    end

    describe 'userResetPassword' do
      let(:params) {
        {
          query: <<-HEREDOC
            mutation {
              userResetPassword(
                resetPasswordToken: "1", 
                password: "2", 
                passwordConfirmation: "3"
              )
            }
          HEREDOC
        }
      }

      it 'calls User.reset_password_by_token' do
        expect(User).to receive(:reset_password_by_token).and_return(double(persisted?: true))
        post '/graphql', params: params
      end

      context 'user is found' do
        before do
          allow(User).to receive(:reset_password_by_token).and_return(FactoryBot.create(:user))
        end

        it 'responds with ok' do
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'userResetPassword')).to eq('ok')
        end
      end

      context 'user is not found' do
        before do
          allow(User).to receive(:reset_password_by_token).and_return(FactoryBot.build(:user))
        end

        it 'responds with error' do
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'userResetPassword')).to eq('error')
        end
      end
    end
  end

end
