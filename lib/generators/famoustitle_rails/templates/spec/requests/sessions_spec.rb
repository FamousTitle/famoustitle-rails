require "rails_helper"

describe 'Sessions', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'POST /users/sign_in' do
    context 'valid credentials' do
      it 'returns success with a new JWT in the header' do
        expect{
          post '/users/sign_in', params: {
              user: {
                  email: user.email,
                  password: user.password
              }
          }
        }.to change{
          user.allowlisted_jwts.count
        }.by(1)

        token = response.headers["Authorization"].split(' ').last
        decoded_jwt = JWT.decode token, nil, false
        expect(decoded_jwt.first['jti']).to eq(user.allowlisted_jwts.last.jti)
      end
    end

    context 'invalid credentials' do
      context 'email does not exist' do
        it 'returns error and does not return a JWT in the header' do
          expect{
            post '/users/sign_in', params: {
                user: {
                    email: "test-#{user.email}",
                    password: user.password
                }
            }
          }.to change{
            user.allowlisted_jwts.count
          }.by(0)
          expect(response.headers["Authorization"]).to be_nil
          expect(response.status).to eq(401)
          expect(JSON.parse(response.body)).to eq({'error' => 'Invalid Email or password.'})
        end
      end

      context 'password does not match' do
        it 'returns error and does not return a JWT in the header' do
          expect{
            post '/users/sign_in', params: {
                user: {
                    email: user.email,
                    password: "test-#{user.password}"
                }
            }
          }.to change{
            user.allowlisted_jwts.count
          }.by(0)
          expect(response.headers["Authorization"]).to be_nil
          expect(response.status).to eq(401)
          expect(JSON.parse(response.body)).to eq({'error' => 'Invalid Email or password.'})
        end
      end
    end
  end

  describe 'DELETE /users' do
    context 'valid JWT' do
      context 'whitelisted JWT matches' do
        let!(:jwt) {
          post '/users/sign_in', params: {
              user: {
                  email: user.email,
                  password: user.password
              }
          }
          response.headers["Authorization"]
        }
        it 'removes the JWT' do
          expect{
            delete '/users/sign_out', headers: {
                'Authorization' => jwt
            }
          }.to change{
            user.allowlisted_jwts.count
          }.by(-1)
          expect(response.status).to eq(204)
        end
      end

      context 'whitelisted JWT does not match' do
        it 'returns 204' do
          expect{
            delete '/users/sign_out'
          }.to change{
            user.allowlisted_jwts.count
          }.by(0)
          expect(response.status).to eq(204)
        end
      end
    end
  end

end
