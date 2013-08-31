# temporary file to handle user registrions
class RegistrationsController < Devise::RegistrationsController

  after_filter :log_event, only: [:create, :destroy]

  private

  # -------------------------------------------------------------
  def log_event
    action = "registrations/#{action_name}"
    log = ActivityLog.new(user: current_user, action: action, info: nil)
    log.save
  end
  
  # --------------------------------------------------------------
  # Let devise know to permit the full_name field at sign-up.
  def sign_up_params
     params.require(:user).permit(:email, :password, :password_confirmation, :full_name)
  end

end
