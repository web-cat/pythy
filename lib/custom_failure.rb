class CustomFailure < Devise::FailureApp

  def redirect_url
    #return super unless [:worker, :employer, :user].include?(scope)
    #make it specific to a scope
    needs_initial_setup? ? root_url : super.redirect_url
  end

  # You need to override respond to eliminate recall
  def respond
    http_auth? ? http_auth : redirect
  end

end
