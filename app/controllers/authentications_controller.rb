class AuthenticationsController < ApplicationController

  # -------------------------------------------------------------
  # GET /authentications
  def index
    @authentications = current_user.authentications if current_user
  end


  # -------------------------------------------------------------
  # POST /authentications
  def create    
    #render :text => request.env["omniauth.auth"].to_yaml

    omniauth = request.env["omniauth.auth"]
    provider = omniauth['provider']
    uid = omniauth['uid']

    authentication = Authentication.find_by_provider_and_uid(provider, uid)

    if authentication
      # Found the authentication, meaning some user has already signed in
      # with this method before. Look up the user from the authentication
      # model and log them in.
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      # Didn't find an authentication, but a user is currently logged in.
      # This means the current user wants to connect this authentication
      # method to their account, so create the authentication object.
      current_user.authentications.create(:provider => provider, :uid => uid)

      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      # Didn't find an authentication and no user is currently logged in.
      # This means we need to create the user and the authentication,
      # then log them in.
      user = User.new
      authentication = user.authentications.build(:provider => provider, :uid => uid)
      authentication.apply_omniauth(user, omniauth)

      user.save!
        flash[:notice] = "Signed in successfully."
        sign_in_and_redirect(:user, user)
      #else
#
#        session[:omniauth] = omniauth.except('extra')
#        redirect_to new_user_registration_url
#      end
    end
  end


  # -------------------------------------------------------------
  # DELETE /authentications/1
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy

    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

end
