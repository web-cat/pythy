class SessionsController < Devise::SessionsController

  before_filter :log_event, only: [:create, :destroy]

end
