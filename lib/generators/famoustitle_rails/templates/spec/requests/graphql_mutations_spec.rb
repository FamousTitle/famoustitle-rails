require "rails_helper"

describe 'GraphqlMutations', type: :request do

  describe 'POST /graphql' do
    describe 'sendPasswordResetToken' do
      let(:params) {
        {
          query: <<-HEREDOC
            mutation {
              sendPasswordResetToken(input: { email: "some@email.com" }) {
                success
              }
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

        it 'responds with success' do
          post '/graphql', params: params
        json_body = JSON.parse(response.body)
        expect(json_body.dig('data', 'sendPasswordResetToken', 'success')).to eq(true)
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

        it 'responds with success' do
          allow(UserNotifierMailer).to receive(:send_password_reset_email).and_return(double(deliver: true))
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'sendPasswordResetToken', 'success')).to eq(true)
        end
      end

    end

    describe 'userResetPassword' do
      let(:params) {
        {
          query: <<-HEREDOC
            mutation {
              userResetPassword(input: {
                resetPasswordToken: "1", 
                password: "2", 
                passwordConfirmation: "3"
              }) {
                success
                errors
                user {
                  id
                }
              }
            }
          HEREDOC
        }
      }

      it 'calls User.reset_password_by_token' do
        expect(User).to receive(:reset_password_by_token).and_return(double(id: 1, persisted?: true))
        post '/graphql', params: params
      end

      context 'user is found' do
        let!(:user) { FactoryBot.create(:user) }

        before do
          allow(User).to receive(:reset_password_by_token).and_return(user)
        end

        it 'responds with ok' do
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          results = json_body.dig("data", "userResetPassword")
          expect(results['success']).to eq(true)
          expect(results['errors']).to eq([])
          expect(results.dig('user', 'id')).to eq(user.id.to_s)
        end
      end

      context 'user is not found' do
        before do
          allow(User).to receive(:reset_password_by_token).and_return(FactoryBot.build(:user))
        end

        it 'responds with error' do
          post '/graphql', params: params
          json_body = JSON.parse(response.body)
          results = json_body.dig("data", "userResetPassword")
          expect(results['success']).to eq(false)
          expect(results['errors']).to eq(['error'])
          expect(results.dig('user', 'id')).to eq(nil)
        end
      end
    end
  end

end
