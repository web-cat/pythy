source 'https://rubygems.org'

gem 'rails', '4.0.0'
gem 'puma'
gem 'mysql2'

group :development, :test do
  gem 'sqlite3', '~> 1.3.4'
  gem 'quiet_assets'
  gem 'pg'              # Postgres db support
end

group :development do
  gem 'annotate'
  gem 'rails-erd'
  gem 'rspec-rails', '2.13.1'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'factory_girl_rails', '4.2.1'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.7.1'
end

gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'coffee-script-source', '1.5.0'
gem 'uglifier', '>= 1.0.3'

# Fundamental gems for view generation and styling.
gem 'json'
gem 'haml', '>= 3.1.4'
gem 'jquery-rails'
gem 'therubyracer'
gem 'less-rails', '2.3.3'
gem 'twitter_bootstrap_form_for',
  git: 'git://github.com/stouset/twitter_bootstrap_form_for.git',
  branch: 'bootstrap-2.0'
gem 'font-awesome-rails'
gem 'codemirror-rails'
gem 'daemon'
gem 'rabl'            # JSON generation

# Gems for authentication and authorization.
gem 'devise', '3.0.0.rc'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'cancan', '1.6.9' # 1.6.10 broke shallow routes

# Various gems for other features used in Pythy.
gem 'fastercsv'       # CSV reading/writing
gem 'kaminari'        # Auto-paginated views
gem 'remotipart'      # Adds support for remote mulitpart forms (file uploads)
gem 'redcarpet'       # Markdown renderer
gem 'delocalize',     # Fixes formatting of date/time form fields
  git: 'git@github.com:elementar/delocalize.git' # Use this fork until Rails 4 support is added to official
gem "git", "~> 1.2.6" # Git repository support
gem 'carrierwave'     # File attachment support
gem 'mime-types'      # MIME types for the above
gem 'jquery-fileupload-rails'  # Better support for file uploads
gem 'mini_magick'     # ImageMagick command-line interface
gem 'uuidtools'       # For generating passkeys for models
gem 'highcharts-rails', '~> 3.0.0'  # For beautiful client-side charts
gem 'gravtastic'      # For Gravatar integration
#gem 'turbolinks'      # Rails 4 turbolinks
gem 'js-routes'       # Route helpers in Javascript
gem 'awesome_print'   # For debugging/logging output
gem 'validates_timeliness', '~> 3.0' # For validating date/time

# Gems for server-side event support.
gem 'redis'
gem 'redis-namespace'
gem 'juggernaut'

# Gems for background job support.
gem 'sidekiq', '~> 2.17.6'
gem 'sidekiq-failures'

# Required for Sidekiq's web-based monitoring interface.
gem 'sinatra', require: false
gem 'slim'

# Temporary gems for backwards-compatibility.
gem 'protected_attributes'

# Gems for deployment.
gem 'capistrano'
