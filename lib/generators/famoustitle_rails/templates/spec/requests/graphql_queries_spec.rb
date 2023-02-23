require "rails_helper"

describe 'GraphqlQueries', type: :request do

  describe 'POST /graphql' do
    describe '#current_user (from authorization)' do
      let(:params) {
        {
          query: <<-HEREDOC
            query currentUser {
              currentUser {
                id
                email
              }
            }
          HEREDOC
        }
      }

      let!(:user) { FactoryBot.create(:user) }
      let!(:auth_token) {
        post '/users/sign_in',
          headers: {"JWT-AUD": "web"},
          params: {
            user: {
                email: user.email,
                password: user.password,
            }
          }

        response.headers["Authorization"]
      }

      before(:each) do
        cookies.delete(cookies.to_hash.keys.first)
      end

      context 'Authorization and AUD does not match' do
        it 'returns empty data' do
          post '/graphql',
            headers: {"Authorization": 'no match', "JWT-AUD": "nope"},
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser')).to eq(nil)
        end
      end

      context 'Authorization matches, but AUD does not match' do
        it 'returns empty data' do
          post '/graphql',
            headers: {"Authorization": auth_token, "JWT-AUD": "nope"},
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser')).to eq(nil)
        end
      end

      context 'Authorization does not match, but AUD matches' do
        it 'returns empty data' do
          post '/graphql',
            headers: {"Authorization": auth_token, "JWT-AUD": "nope"},
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser')).to eq(nil)
        end
      end

      context 'Authorization and AUD matches' do
        it 'returns present data' do
          post '/graphql',
            headers: {"Authorization": auth_token, "JWT-AUD": "web"},
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser', 'email')).to eq(user.email)
        end
      end
    end

    describe 'currentUser' do
      let(:params) {
        {
          query: <<-HEREDOC
            query currentUser {
              currentUser {
                id
                email
              }
            }
          HEREDOC
        }
      }
      
      context 'current_user is not authorized' do
        before do
          allow_any_instance_of(GraphqlController).to receive(:current_user).and_return(nil)
        end

        it 'returns empty data' do
          post '/graphql',
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser')).to eq(nil)
        end
      end

      context 'current_user is authorized' do
        let!(:user) { FactoryBot.create(:user) }

        before do
          allow_any_instance_of(GraphqlController).to receive(:current_user).and_return(user)
        end

        it 'returns empty data' do
          post '/graphql',
            params: params
              
          json_body = JSON.parse(response.body)
          expect(json_body.dig('data', 'currentUser', 'email')).to eq(user.email)
        end
      end
    end

  end

end
