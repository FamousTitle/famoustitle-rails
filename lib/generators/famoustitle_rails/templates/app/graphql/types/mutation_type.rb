module Types
  class MutationType < Types::BaseObject
  
    field :send_password_reset_token, mutation: Mutations::Session::SendPasswordResetToken

    field :user_reset_password, mutation: Mutations::Session::UserResetPassword

    field :update_user, mutation: Mutations::Users::Update

  end
end
