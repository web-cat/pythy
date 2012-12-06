class ApplicationController < ActionController::Base
  layout :determine_layout

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protect_from_forgery

  # checks if a user is logged in, and chooses which layout to
  # frame the application with
  private
  def determine_layout
    current_user ? 'logged_in' : 'not_logged_in'
  end
end
