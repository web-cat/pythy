module ApplicationHelper

  # -------------------------------------------------------------
  # Gets a value indicating whether the application needs to present the
  # initial setup screen. This is currently true if the User table is empty,
  # meaning that nobody has accessed the application and created the initial
  # admin user.
  #
  def needs_initial_setup?
    User.count == 0
  end
  
  # -------------------------------------------------------------
  # Returns the correct twitter bootstrap class mapping for different
  # types of flash messages
  # 
  def flash_class(level)
    case level
    when :notice then "alert-info"
    when :error then "alert-error"
    when :alert then ""
    end
  end

  # Devise helpers

  # -------------------------------------------------------------
  def resource_name
    :user
  end

  # -------------------------------------------------------------
  def resource
    @resource ||= User.new
  end

  # -------------------------------------------------------------
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # -------------------------------------------------------------
  def devise_error_messages!
    return "" if resource.nil? || resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource_name)

    html = <<-HTML
<div id="error_explanation">
<h2>#{sentence}</h2>
<ul>#{messages}</ul>
</div>
HTML

    html.html_safe
  end

end
