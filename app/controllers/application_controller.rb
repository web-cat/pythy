class ApplicationController < ActionController::Base

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  protect_from_forgery
  helper_method :google_font_link_tag

  private
  def google_font_link_tag(family)
    tag('link', {:rel => :stylesheet,
    :type => Mime::CSS,
    :href => "http://fonts.googleapis.com/css?family=#{family}"},
             false, false)
  end
end
