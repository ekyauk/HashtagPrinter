class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  skip_before_filter :check_login

  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.from_omniauth(request.env["omniauth.auth"])
      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        session[:google_oauth_token] = request.env["omniauth.auth"].credentials.token
        session[:session_length] = request.env["omniauth.auth"].credentials.expires_at
        puts 'aytunayfwntyfwutn'
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end

  # def instagram
  #   if current_user != nil
  #     reponse = Instagram.get_access_token(params[:code])
  #   else
  #     redirect_to new_user_registration_url
  #   end
  # end
end