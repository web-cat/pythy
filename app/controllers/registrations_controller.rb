# temporary file to handle user registrions
class RegistrationsController < Devise::RegistrationsController

  after_filter :log_event, only: [:create, :destroy]

  # Override devise's default create action to redirect administrator
  # to the System Configuration page.
  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        if SystemConfiguration.count == 0 && @user.global_role_id == GlobalRole::ADMINISTRATOR_ID
          flash[:notice] += " Please setup the system configuration paths now."
          respond_with resource, :location => edit_system_configuration_path
        else
          respond_with resource, :location => after_sign_up_path_for(resource)
        end        
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        if SystemConfiguration.count == 0 && @user.global_role_id == GlobalRole::ADMINISTRATOR_ID
          flash[:notice] += " Please setup the system configuration paths now."
          respond_with resource, :location => edit_system_configuration_path
        else
          respond_with resource, :location => after_inactive_sign_up_path_for(resource)
        end        
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

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
