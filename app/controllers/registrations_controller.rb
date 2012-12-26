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

end
