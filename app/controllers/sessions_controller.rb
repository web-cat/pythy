class SessionsController < Devise::SessionsController

  layout 'landing'

  before_filter :log_event, only: [:create, :destroy]

end
