module ApplicationHelper

  # -------------------------------------------------------------
  # Gets a value indicating whether the application needs to present the
  # initial setup screen. This is currently true if the User table is empty,
  # meaning that nobody has accessed the application and created the initial
  # admin user.
  #
  def needs_initial_setup?
    User.all.empty?
  end

end
