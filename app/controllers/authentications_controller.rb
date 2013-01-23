class AuthenticationsController < ApplicationController

  before_filter :authenticate_user!, except: :create

  # -------------------------------------------------------------
  # GET /authentications
  def index
    @authentications = current_user.authentications if current_user
  end


  # -------------------------------------------------------------
  # POST /authentications
  def create    
    omniauth = request.env['omniauth.auth']
    provider = omniauth['provider']
    uid = omniauth['uid']

    authentication = Authentication.find_by_provider_and_uid(provider, uid)

    if authentication && authentication.user.present?
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
      redirect_to root_url
    else
      # Didn't find an authentication and no user is currently logged in.
      # First, let's see if a user with the e-mail address exists; they
      # might have been uploaded in a course roster. If no user was found,
      # we need to create the user.

      user = find_user(omniauth) || User.new
      authentication = user.authentications.build(:provider => provider, :uid => uid)
      authentication.apply_omniauth(user, omniauth)
      user.save!

      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
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


  private

  # -------------------------------------------------------------
  def find_user(omniauth)
    # FIXME This method contains some Virginia Tech specific hacks (mainly due
    # to the fact that I'm unsure about whether the roll files downloaded from
    # Banner list the student's preferred e-mail alias or their PID@vt.edu.
    # We'll need to move this code out of here permanently at some point.

    extra = omniauth['info']['extra']
    main_email = omniauth['info']['email']

    if main_email =~ /@(.*)$/
      domain = $1
    elsif main_email.blank?
      # FIXME Ugly ugly quick hack to append PID and vt.edu when an e-mail
      # address is confidential.
      domain = 'vt.edu'
    end

    emails = []
    emails << main_email

    extra = omniauth['extra']
    if extra && extra['raw_info'].uupid
      emails << "#{extra['raw_info'].uupid.first}@#{domain}"
    end

    User.find_by_email(emails)
  end

end
