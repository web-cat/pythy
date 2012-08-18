include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  # Provide the initial setup routes if the User table is empty.
  scope :constraints => lambda { |req| needs_initial_setup? } do
    match 'setup(/:action)', :controller => 'setup', :as => 'setup'
    root :to => "setup#index"
  end

  # Routes for Devise authentication.
  devise_for :users, :controllers => {
    :sessions => 'sessions',
    :registrations => 'registrations'
  }

  # Default route for the site's root.
  root :to => 'home#index'

end
