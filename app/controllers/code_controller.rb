class CodeController < FriendlyUrlController

  DEFAULT_FILE = 'main.py'

  SUPPORTED_MESSAGES = %w(add_user)

  before_filter :find_repository

  # -------------------------------------------------------------
  def show
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
        Juggernaut.publish 'code_updated', { code: code },
          except: request.headers['X-Session-ID']
        format.js
      else
        format.js { render nothing: true }
      end
    end
  end


  # -------------------------------------------------------------
  def message
    message = params[:message].to_s
    if SUPPORTED_MESSAGES.include? message
      send message
    else
      not_found
    end
  end


  # -------------------------------------------------------------
  # Called when a new user opens the code controller for a particular
  # repository.
  def add_user
    path = File.join(@repository.git_path, @filename)

    begin
      code = File.read(path)

      Juggernaut.publish 'code_updated', { code: code },
        except: request.headers['X-Session-ID']
    rescue
    end
    
    respond_to do |format|
      format.js { render nothing: true }
    end
  end


  private

  # -------------------------------------------------------------
  def find_repository
    parts = params[:rest].split('/')

    if parts.first == 'example'
      id = parts.second
      @filename = parts.length > 2 ? parts[2] : DEFAULT_FILE

      @repository = ExampleRepository.find_by_id(id)
      @page_title = "#{@repository.course_offering.course.department_name_and_number} &ndash; Example: #{@repository.name}"
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
