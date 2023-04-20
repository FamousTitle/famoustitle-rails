module Mutations
  module Users
    class Update < BaseMutation
      argument :password, String, required: false
      argument :password_confirmation, String, required: false
      
      field :success, Boolean, null: false
      field :errors, [String], null: false
      field :user, Types::Models::UserType, null: true
  
      def resolve(**args)
        user = context[:current_user]
        if user.blank?
          return { success: false, user: user, errors: ['Unauthorized'] }
        end
  
        begin
          user.assign_attributes(args)
          user.save!
          return { success: true, user: user, errors: [] }
        rescue => exception
          user.errors.add(:base, exception)
        end
  
        { success: false, user: user, errors: user.errors.full_messages }
  
      end
  
    end
  end
end
