source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'thin'

group :development, :test do
  gem 'sqlite3', '~> 1.3.4'
  gem 'mysql2'
  gem 'quiet_assets'
end

group :production do
  gem 'mysql2'
end

gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'

# Fundamental gems for view generation and styling.
gem 'json'
gem 'haml', '>= 3.1.4'
gem 'jquery-rails'
gem 'therubyracer'
gem 'less-rails'
gem 'twitter_bootstrap_form_for',
  git: 'git://github.com/stouset/twitter_bootstrap_form_for.git',
  branch: 'bootstrap-2.0'
gem 'font-awesome-rails'
gem 'codemirror-rails'
gem 'daemon'

# Gems for authentication and authorization.
gem 'devise'
gem 'devise_ldap_authenticatable',
  git: 'git://github.com/cschiewek/devise_ldap_authenticatable.git'
gem 'net-ldap'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-ldap',
  git: 'git://github.com/web-cat/omniauth-ldap.git'
gem 'cancan'

# Various gems for other features used in Pythy.
gem 'fastercsv'       # CSV reading/writing
gem 'kaminari'        # Auto-paginated views
gem 'remotipart'      # Adds support for remote mulitpart forms (file uploads)
gem 'redcarpet'       # Markdown renderer
gem 'rails_admin'     # Turnkey admin interface
gem 'delocalize'      # Fixes formatting of date/time form fields
gem 'git'             # Git repository support

# Gems for server-side event support.
gem 'redis'
gem 'redis-namespace'
gem 'juggernaut'

# Gems for background job support.
gem 'sidekiq'
gem 'sidekiq-failures'

# Required for Sidekiq's web-based monitoring interface.
gem 'sinatra', require: false
gem 'slim'

# Gems for deployment.
gem 'capistrano'
