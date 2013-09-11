default_run_options[:pty] = true

set :user,        'pythystaging'
set :db_user,     'pythystaging'

set :branch,      'master'
set :rails_env,   'staging'
set :deploy_to,   "/home/#{user}/rails"

after 'uploads:symlink', 'deploy:symlink_db'

namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end
