require 'bundler/capistrano'

#
# Instance-specific settings. Change these if deploying to a different
# server.
#
set :domain,      "pythy.cs.vt.edu"
set :deploy_to,   "/home/pythy/rails"
set :user,        "pythy"
set :db_user,     "pythy"
set :use_sudo,    false

#
# Project-specific settings. Only edit if necessary.
#
set :application, "Pythy"
set :scm,         :git
set :repository,  "git://github.com/web-cat/pythy.git"
set :branch,      "master"
set :repository_cache, "git_cache"
set :deploy_via,  :remote_cache
set :ssh_options, { :forward_agent => true }

set :development_database, "#{application}_dev"
set :test_database,        "#{application}_test"
set :production_database,  "#{application}"

role :web, domain
role :app, domain
role :db,  domain, :primary => true


#
# Tasks related to application deployment.
#
namespace :deploy do

  # -------------------------------------------------------------
  task :start do ; end

  # -------------------------------------------------------------
  task :stop do ; end

  # -------------------------------------------------------------
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

end

#
# Tasks related to database configuration and migration.
#
namespace :db do

  # -------------------------------------------------------------
  desc "Create database.yml in shared path"
  task :configure do
    set :db_password do
      Capistrano::CLI.password_prompt "Password for database user '#{db_user}': "
    end
    
    db_config = <<-EOF
base: &base
  adapter: mysql
  encoding: utf8
  username: #{db_user}
  password: #{db_password}

development:
  database: #{development_database}
  <<: *base

test:
  database: #{test_database}
  <<: *base

production:
  database: #{production_database}
  <<: *base
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

  # -------------------------------------------------------------
  desc "Make symlink for database.yml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  # -------------------------------------------------------------
  desc "Run database migrations"
  task :migrate, :roles => :app do
    run "cd #{current_path}; bundle exec rake db:migrate RAILS_ENV=production"
  end

end

before "deploy:setup",       "db:configure"
after  "deploy:update_code", "db:symlink"
