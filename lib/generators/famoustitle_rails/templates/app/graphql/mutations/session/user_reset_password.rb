module Mutations
  module Session
    class UserResetPassword < BaseMutation
      argument :reset_password_token, String, required: true
      argument :password, String, required: true
      argument :password_confirmation, String, required: true

      field :success, Boolean, null: false
      field :errors, [String], null: false
      field :user, Types::Models::UserType, null: true
  
      def resolve(**args)
        reset_password_token = args[:reset_password_token]
        password = args[:password]
        password_confirmation = args[:password_confirmation]

        user = User.reset_password_by_token(
          reset_password_token: reset_password_token,
          password: password,
          password_confirmation: password_confirmation
        )

        if user.persisted?
          { success: true, user: user, errors: [] }
        else
          { success: false, user: user, errors: ['error'] }
        end
      end
  
    end
  end
end
