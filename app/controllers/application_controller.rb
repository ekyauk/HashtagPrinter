class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_login

  private

  def user_is_valid
    return current_user != nil &&
        session[:session_expiration] > Time.now.utc.to_i
  end

  def check_login
    if !user_is_valid
        reset_session
        redirect_to :new_user
    end
  end
end
