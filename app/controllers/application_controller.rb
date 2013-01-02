class ApplicationController < ActionController::Base

  layout :determine_layout

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  # -------------------------------------------------------------
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,
      with: lambda { |exception| render_error 500, exception }
    
    rescue_from ActionController::RoutingError,
      ActionController::UnknownController,
      ::AbstractController::ActionNotFound,
      ActiveRecord::RecordNotFound,
      with: lambda { |exception| render_error 404, exception }

    rescue_from CanCan::AccessDenied,
      with: lambda { |exception| render_error 403, exception }
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


  # -------------------------------------------------------------
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end


  private

  # -------------------------------------------------------------
  # Checks if a user is logged in, and chooses which layout to
  # frame the application with.
  def determine_layout
    current_user ? 'logged_in' : 'not_logged_in'
  end


  # -------------------------------------------------------------
  def render_error(status, exception)
    # For 500s, log the error.
    # TODO: Send admin users an e-mail with the trace.
    if status == 500
      logger.error "Unhandled Exception: #{exception.message}"
      exception.backtrace.each { |line| logger.error "  #{line}" }
    end

    respond_to do |format|
      format.html do
        render template: "errors/error_#{status}",
          layout: 'layouts/plain', status: status
      end
      format.all { render nothing: true, status: status }
    end
  end

end
