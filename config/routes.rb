require 'sidekiq/web'

include ApplicationHelper   # Brings in needs_initial_setup?

Pythy::Application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'

  post '/auth/:provider/callback' => 'authentications#create'
  resources :authentications

  # Provide the initial setup routes if the User table is empty.
  scope :constraints => lambda { |req| needs_initial_setup? } do
    get 'setup(/:action)', controller: 'setup', as: 'setup'
    get '/', to: 'setup#index', as: nil
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
    as: 'activity_logs', via: [:get, :post]

  resources :terms
  resources :global_roles
  resources :course_roles
  resources :environments

  resources :assignment_repositories, shallow: true do
    resources :assignment_checks
  end

  resources :scratchpad_repositories

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

  get 'typeaheads/user', to: 'typeaheads#user'

  match 'course_offering/:course_offering_id/upload_roster/:action',
    controller: 'upload_roster', as: 'upload_roster', via: [:get, :post]

  match 'self_enroll/:action',
    controller: 'self_enrollment', as: 'self_enrollment', via: [:get, :post]
    
  get 'assignments/:id/regrade_all/:offering_id' => 'assignments#regrade_all', as: 'assignment_regrade_all'
  get 'assignments/:id/regrade/:offering_id/:repository_id' => 'assignments#regrade', as: 'assignment_regrade'

  # Route for viewing code. The constraints allow project and file names to
  # include dots, which would normally be interpreted by Rails' router as a
  # format indicator.
  code_pattern = 'code(/:organization/:course/:term(/offering_:offering))/:rest'
  get code_pattern => 'code#show', constraints: { rest: /.+/ }
  put code_pattern => 'code#update', constraints: { rest: /.+/ }
  post code_pattern => 'code#message', constraints: { rest: /.+/ }

  match 'home' => 'home#index', via: [:get, :post]
  match 'home/:organization/:course/:term' => 'home#course',
    via: [:get, :post]

  # Route for accessing the media library.
  medias_pattern = 'media(/user/:user)(/assignment/:assignment)'
  media_pattern = "#{medias_pattern}(/:filename)"
  get medias_pattern => 'media#index', constraints: { filename: /.+/ }
  get media_pattern => 'media#show', constraints: { filename: /.+/ }
  post media_pattern => 'media#create', constraints: { filename: /.+/ }
  delete 'media/:id' => 'media#destroy'

  # External content proxy, to get around HTTPS issues when Python code makes
  # requests to external sites.
  get 'proxy' => 'proxy#get', as: 'proxy'  

  # Default route when a user is logged in.
  authenticated :user do
    root to: redirect('/home')
  end

  # Default route when a user is not logged in.
  get '/', to: 'landing#index', as: 'landing'

  unless Rails.application.config.consider_all_requests_local
    get '*not_found', to: 'errors#error_404'
  end

end