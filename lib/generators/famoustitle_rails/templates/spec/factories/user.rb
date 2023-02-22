FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }

    transient do
      aud { 'web' }
      exp { 8.hours.since }
    end

    before :create do |user|
      pass = Faker::Internet.password(min_length: 10, max_length: 20)
      user.password = pass
      user.password_confirmation = pass
      user.save
    end

    after :create do |user, options|
      user.allowlisted_jwts.create(
          jti: SecureRandom.uuid,
          aud: options.aud,
          exp: options.exp
      )
    end

  end

end
