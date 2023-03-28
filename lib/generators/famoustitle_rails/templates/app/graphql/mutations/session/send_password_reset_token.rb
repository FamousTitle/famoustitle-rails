module Mutations
  module Session
    class SendPasswordResetToken < BaseMutation
      argument :email, String, required: true

      field :success, Boolean, null: false
      field :errors, [String], null: false
      field :user, Types::Models::UserType, null: true
  
      def resolve(**args)
        email = args[:email]
        
        user = User.find_by(email: email)
        user.send_password_reset_email if user.present?
        { success: true, user: user, errors: [] }
      end
  
    end
  end
end
