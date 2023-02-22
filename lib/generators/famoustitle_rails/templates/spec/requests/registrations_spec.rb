require "rails_helper"

describe 'Registrations', type: :request do
  let!(:user) { FactoryBot.build(:user, password: '12345678') }

  describe 'POST /users' do
    context 'valid credentials' do
      it 'returns a JWT in the header' do
        expect{
          post '/users', params: {
              user: {
                  email: user.email,
                  password: user.password
              }
          }
        }.to change{
          User.count
        }.by(1).and change{
          AllowlistedJwt.count
        }.by(1)

        expect(response.status).to eq(201)
      end
    end

    context 'invalid credentials' do
      context 'not a valid email' do
        it 'returns invalid email error message' do
          expect{
            post '/users', params: {
                user: {
                    email: 'hi',
                    password: user.password
                }
            }
          }.to change{
            User.count
          }.by(0).and change{
            AllowlistedJwt.count
          }.by(0)

          expect(response.status).to eq(422)
          expect(JSON.parse(response.body).dig('errors', 'email')).to eq(['is invalid'])
        end
      end

      context 'email already exists' do
        let!(:existing_user) { FactoryBot.create(:user) }

        it 'returns already exist error message' do
          expect{
            post '/users', params: {
                user: {
                    email: existing_user.email,
                    password: existing_user.password,
                    password_confirmation: existing_user.password
                }
            }
          }.to change{
            User.count
          }.by(0).and change{
            AllowlistedJwt.count
          }.by(0)

          expect(response.status).to eq(422)
          expect(JSON.parse(response.body).dig('errors', 'email')).to eq(["has already been taken"])
        end
      end

      context 'passwords do not match' do
        it 'returns passwords do not match error message' do
          expect{
            post '/users', params: {
                user: {
                    email: user.email,
                    password: '12345678',
                    password_confirmation: '87654321'
                }
            }
          }.to change{
            User.count
          }.by(0).and change{
            AllowlistedJwt.count
          }.by(0)

          expect(response.status).to eq(422)
        end
      end
    end
  end

end
