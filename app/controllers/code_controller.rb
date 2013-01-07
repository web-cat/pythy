require 'redis'

class CodeController < FriendlyUrlController

  DEFAULT_FILE = 'main.py'

  ALLOWED_MESSAGES = %w(add_user remove_user unsync resync ping)

  before_filter :find_repository

  # -------------------------------------------------------------
  def show
    @subscribe_channel = subscribe_channel(nil)
  end


  # -------------------------------------------------------------
  def update
    authorize! :update, @repository

    code = params[:code]

    # Update the code in the working copy of the repo.
    path = File.join(@repository.git_path, @filename)
    File.open(path, 'w') { |f| f.write(code) }

    git = @repository.open
    git.add path

    committed = true

    begin
      git.commit_all "Updated by #{current_user.display_name}",
        author: "#{current_user.display_name} <#{current_user.email}>"
    rescue Git::GitExecuteError => e
      if e.message =~ /nothing to commit/
        committed = false
      else
        raise e
      end
    end

    respond_to do |format|
      if committed
        puts "PUSHING THE CODE"
        publish(:code) do
          render_to_string template: 'code/update_code',
            locals: { code: code, force: false }
        end

        format.js
      else
        format.js { render nothing: true }
      end
    end
  end


  # -------------------------------------------------------------
  def message
    message = params[:message].to_s
    if ALLOWED_MESSAGES.include? message
      send message
    else
      not_found
    end
  end


  private

  # -------------------------------------------------------------
  # Called when a new user opens the code controller for a particular
  # repository.
  def add_user
    @repository.connect_user current_user
    users = @repository.connected_users.alphabetical

    path = File.join(@repository.git_path, @filename)

    begin
      code = File.read(path)
      
      publish(:users) do
        render_to_string template: 'code/update_user_list',
          locals: { users: users }
      end

      respond_to do |format|
        format.js { render template: 'code/update_code',
          locals: { code: code, force: true } }
      end
    rescue IOError
      respond_to do |format|
        format.js { render nothing: true }
      end      
    end
    
  end


  # -------------------------------------------------------------
  # Called when a new user opens the code controller for a particular
  # repository.
  def remove_user
    @repository.disconnect_user current_user
    users = @repository.connected_users.alphabetical

    publish(:users) do
      render_to_string template: 'code/update_user_list',
        locals: { users: users }
    end
    
    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  # -------------------------------------------------------------
  def unsync
    @repository.unsync_user current_user
    users = @repository.connected_users.alphabetical

    publish(:users) do
      render_to_string template: 'code/update_user_list',
        locals: { users: users }
    end

    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  # -------------------------------------------------------------
  def resync
    @repository.sync_user current_user
    users = @repository.connected_users.alphabetical

    path = File.join(@repository.git_path, @filename)

    begin
      code = File.read(path)

      publish(:users) do
        render_to_string template: 'code/update_user_list',
          locals: { users: users }
      end

      respond_to do |format|
        format.js { render template: 'code/update_code',
          locals: { code: code, force: true } }
      end
    rescue IOError
      respond_to do |format|
        format.js { render nothing: true }
      end
    end
  end


  # -------------------------------------------------------------
  def ping
    @repository.connect_user current_user

    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  # -------------------------------------------------------------
  def subscribe_channel(name)
    id = @repository.source_repository ? @repository.source_repository.id :
      @repository.id

    if name
      "#{@repository.class.name}_#{id}_#{name.to_s}"
    else
      "#{@repository.class.name}_#{id}"
    end
  end


  # -------------------------------------------------------------
  def publish(channel, &block)
    options = { javascript: block.call }
    Juggernaut.publish subscribe_channel(channel), options,
      except: request.headers['X-Session-ID']
  end


  # -------------------------------------------------------------
  def find_repository
    parts = params[:rest].split('/')

    if parts.first == 'example'
      id = parts.second
      @filename = parts.length > 2 ? parts[2] : DEFAULT_FILE

      @repository = ExampleRepository.find_by_id(id)

      if @repository
        @page_title = "#{@repository.course_offering.course.department_name_and_number} &ndash; Example: #{@repository.name}"
      end
    end

    # Make sure the user has access to read the repository, or raise a
    # not-found exception if it wasn't found.
    if @repository
      authorize! :read, @repository
    else
      not_found
    end
  end

end
