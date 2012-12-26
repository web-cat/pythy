class ApplicationController < ActionController::Base

  layout :determine_layout

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied!"
    redirect_to root_url
  end

  protect_from_forgery


  # -------------------------------------------------------------
  # Logs a controller action to the database. Used for session logging as
  # well as tracking other actions.
  def log_event(info = nil)
    if current_user
      action = "#{controller_name}/#{action_name}"
      log = ActivityLog.new(user: current_user, action: action, info: info)
      log.save
    end
  end


  private

  # -------------------------------------------------------------
  # Checks if a user is logged in, and chooses which layout to
  # frame the application with.
  def determine_layout
    current_user ? 'logged_in' : 'not_logged_in'
  end

end
