include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  mount RailsAdmin::Engine => 'rails_admin'

  resources :assignment_offerings

  resources :assignments

  resources :course_offerings

  resources :courses

  resources :terms

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

  scope "/admin" do
    resources :users
    resources :global_roles
    resources :departments
    resources :institutions
  end

  # Route for viewing code.
  match 'code(/:action)', :controller => 'code'

  # Default route when a user is logged in.
  authenticated :user do
    root :to => 'home#index'
  end

  # Default route when a user is not logged in.
  root :to => 'landing#index'

end
