default_run_options[:pty] = true

set :user,        'pythy'
set :db_user,     'pythy'

set :branch,      'stable'
set :rails_env,   'production'
set :deploy_to,   "/home/#{user}/rails"

after 'uploads:symlink', 'deploy:symlink_db'

namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end
