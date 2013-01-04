class CodeController < FriendlyUrlController

  DEFAULT_FILE = 'main.py'

  ALLOWED_MESSAGES = %w(add_user resync)

  before_filter :find_repository

  # -------------------------------------------------------------
  def show
    @subscribe_channel = subscribe_channel
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
        publish action: 'code_updated', code: code
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
    path = File.join(@repository.git_path, @filename)

    begin
      code = File.read(path)
      publish action: 'code_updated', code: code
    rescue
    end
    
    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  # -------------------------------------------------------------
  def resync
    path = File.join(@repository.git_path, @filename)

    begin
      code = File.read(path)
      self_publish action: 'code_updated', code: code
    rescue
    end
    
    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  # -------------------------------------------------------------
  def subscribe_channel
    id = @repository.source_repository ? @repository.source_repository.id :
      @repository.id
    "#{@repository.class.name}_#{id}"
  end


  # -------------------------------------------------------------
  def publish(options = {})
    Juggernaut.publish subscribe_channel, options,
      except: request.headers['X-Session-ID']
  end


  # -------------------------------------------------------------
  def self_publish(options = {})
    Juggernaut.publish subscribe_channel, options,
      only: request.headers['X-Session-ID']
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
