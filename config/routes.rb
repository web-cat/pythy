require 'sidekiq/web'

include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  mount RailsAdmin::Engine => 'rails_admin'
  mount Sidekiq::Web, at: '/sidekiq'

  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications

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

  resource :system_configuration, except: :destroy

  match 'activity(/:action)', controller: 'activity_logs',
    as: 'activity_logs'

  resources :terms
  resources :global_roles
  resources :course_roles

  resources :assignment_repositories, shallow: true do
    resources :assignment_checks
  end

  shallow do
    resources :organizations do
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

  match 'typeaheads/user', to: 'typeaheads#user'

  match 'course_offering/:course_offering_id/upload_roster/:action',
    controller: 'upload_roster', as: 'upload_roster'

  match 'self_enroll/:action',
    controller: 'self_enrollment', as: 'self_enrollment'

  # Route for viewing code. The constraints allow project and file names to
  # include dots, which would normally be interpreted by Rails' router as a
  # format indicator.
  code_pattern = 'code(/:organization(/:course(/:term(/:offering(/:rest)))))'
  match code_pattern => 'code#show', via: :get, constraints: { rest: /.+/ }
  match code_pattern => 'code#update', via: :put, constraints: { rest: /.+/ }
  match code_pattern => 'code#message', via: :post, constraints: { rest: /.+/ }

  match 'home(/:organization(/:course(/:term(/:offering))))' => 'home#index'

  # Route for accessing the media library.
  medias_pattern = 'media(/user/:user)(/assignment/:assignment)'
  media_pattern = "#{medias_pattern}(/:filename)"
  match medias_pattern => 'media#index', via: :get, constraints: { filename: /.+/ }
  match media_pattern => 'media#show', via: :get, constraints: { filename: /.+/ }
  match media_pattern => 'media#create', via: :post, constraints: { filename: /.+/ }
  match 'media/:id' => 'media#destroy', via: :delete

  # External content proxy, to get around HTTPS issues when Python code makes
  # requests to external sites.
  match 'proxy' => 'proxy#get', as: 'proxy'  

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
