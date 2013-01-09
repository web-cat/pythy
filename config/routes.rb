require 'sidekiq/web'

include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  mount RailsAdmin::Engine => 'rails_admin'
  mount Sidekiq::Web, at: '/sidekiq'

  match '/auth/:provider/callback' => 'authentications#create'

  resource :system_configuration, except: :destroy

  resources :authentications
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

  resources :users do
    get 'impersonate', on: :member
    get 'unimpersonate', on: :collection
  end

  resources :global_roles
  resources :course_roles

  resources :institutions, shallow: true do
    resources :departments do
      resources :courses do
        resources :assignments
        resources :course_offerings do
          resources :assignment_offerings
          resources :course_enrollments
          resources :example_repositories, path: 'examples'
        end
      end
    end
  end

  match 'course_offering/:course_offering_id/upload_roster/:action',
    controller: 'upload_roster', as: 'upload_roster'

  # Route for viewing code. The constraints allow project and file names to
  # include dots, which would normally be interpreted by Rails' router as a
  # format indicator.
  code_pattern = 'code(/:institution(/:term(/:course(/:crn(/:rest)))))'
  match code_pattern => 'code#show', via: :get, constraints: { rest: /.+/ }
  match code_pattern => 'code#update', via: :put, constraints: { rest: /.+/ }
  match code_pattern => 'code#message', via: :post, constraints: { rest: /.+/ }

  match 'home(/:institution(/:term(/:course(/:crn))))' => 'home#index'

  # Default route when a user is logged in.
  authenticated :user do
    root to: redirect('/home')
  end

  # Default route when a user is not logged in.
  root to: 'landing#index'

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', to: 'errors#error_404'
  end

end
