class AuthenticatedController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  private

  # need to override devise's authenticate_user! 
  # because we want :unauthorized instead of redirect
  def authenticate_user!
    return head :unauthorized if current_user.blank?
  end

end
