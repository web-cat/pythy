require 'bundler/capistrano'

#
# Set up the stages that we can deploy to. The default is 'staging', so that
# we don't accidentally put stuff into production that we don't want to.
#
set :stages,               %w(staging production)
set :default_stage,        'staging'
require 'capistrano/ext/multistage'
require 'sidekiq/capistrano'

#
# Instance-specific settings. Change these if deploying to a different
# server.
#
set :domain,               'pythy.cs.vt.edu'
set :use_sudo,             false

#
# Project-specific settings. Only edit if necessary.
#
set :application,          'pythy'
set :scm,                  :git
set :repository,           'git://github.com/web-cat/pythy.git'
set :repository_cache,     'git_cache'
set :deploy_via,           :remote_cache
set :ssh_options,          { forward_agent: true }

set :development_database, "#{application}_dev"
set :staging_database,     "#{application}_staging"
set :test_database,        "#{application}_test"
set :production_database,  "#{application}"

role :web, domain
role :app, domain
role :db,  domain, primary: true


#
# Tasks related to application deployment.
#
namespace :deploy do

  # -------------------------------------------------------------
  task :start, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  # -------------------------------------------------------------
  task :stop do ; end

  # -------------------------------------------------------------
  task :restart, roles: :app, except: { no_release: true } do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  # -------------------------------------------------------------
  desc "load the database with seed data"
  task :seed do
    run "cd #{current_path} && bundle exec rake db:seed RAILS_ENV=#{stage}"
  end

end

#
# Tasks related to database configuration and migration.
#
namespace :db do

  # -------------------------------------------------------------
  desc 'Create database.yml in shared path'
  task :configure do
    set :db_password do
      Capistrano::CLI.password_prompt "Password for database user '#{db_user}': "
    end
    
    db_config = <<-EOF
base: &base
  adapter: mysql2
  encoding: utf8
  username: #{db_user}
  password: #{db_password}

development:
  database: #{development_database}
  <<: *base

test:
  database: #{test_database}
  <<: *base

staging:
  database: #{staging_database}
  <<: *base

production:
  database: #{production_database}
  <<: *base
    EOF

    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

  # -------------------------------------------------------------
  desc 'Make symlink for database.yml'
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end

  # -------------------------------------------------------------
  desc 'Create database'
  task :create do
    run "cd #{current_path}; bundle exec rake db:create RAILS_ENV=#{stage}"
  end

  # -------------------------------------------------------------
  desc 'Run database migrations'
  task :migrate, roles: :app do
    run "cd #{current_path}; bundle exec rake db:migrate RAILS_ENV=#{stage}"
  end

end

before 'deploy:setup',       'db:configure'
after  'deploy:update_code', 'db:symlink'
