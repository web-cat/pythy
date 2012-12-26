include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  mount RailsAdmin::Engine => 'rails_admin'

  match '/auth/:provider/callback' => 'authentications#create'

  resources :authentications
  resources :assignment_offerings
  resources :course_offerings
  resources :terms

  match 'activity(/:action)', controller: 'activity_logs',
    as: 'activity_logs'

  # Provide the initial setup routes if the User table is empty.
  scope constraints: ->(req) { needs_initial_setup? } do
    match 'setup(/:action)', controller: 'setup', as: 'setup'
    root to: 'setup#index'
  end

  # Routes for Devise authentication.
  devise_for :users, controllers: {
    sessions: 'sessions',
    registrations: 'registrations'
  }

  resources :users
  resources :global_roles
  resources :course_roles

  resources :course_enrollments

  resources :institutions, shallow: true do
    resources :departments do
      resources :courses do
        resources :assignments
      end
    end
  end

  # Route for viewing code.
  match 'code(/:action)', controller: 'code'

  match 'home(/:institution(/:term(/:course)))' => 'home#index'

  # Default route when a user is logged in.
  authenticated :user do
    root to: 'home#index'
  end

  # Default route when a user is not logged in.
  root to: 'landing#index'

end
