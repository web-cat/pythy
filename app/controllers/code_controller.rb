require 'redis'

class CodeController < FriendlyUrlController

  layout 'code'

  DEFAULT_FILE = 'main.py'

  ALLOWED_MESSAGES = %w(hash_change add_user remove_user unsync resync
    ping check start_over check_results history)

  before_filter :authenticate_user!
  before_filter :find_repository

  # -------------------------------------------------------------
  def show
    @subscribe_channel = @repository.event_channel(nil)

    @repository.read do
      path = File.join(@repository.git_path, @filename)
      FileUtils.touch path unless File.exists?(path)
    end

    if @repository.is_a? AssignmentRepository
      a = @repository.assignment_offering.assignment
      @page_title = "#{a.course.number} &ndash; #{a.short_name}: #{a.long_name}"
      @summary = a.brief_summary_html(link: assignment_path(a))
    elsif @repository.is_a? AssignmentReferenceRepository
      a = @repository.assignment
      @page_title = "#{a.course.number} &ndash; #{a.short_name}: #{a.long_name}"
      @summary = a.brief_summary_html(link: assignment_path(a))
    elsif @repository.is_a? ExampleRepository
      @page_title = "#{@repository.course_offering.course.number} &ndash; Example: #{@repository.name}"
      @summary = @repository.description
    end
  end


  # -------------------------------------------------------------
  def update
    authorize! :update, @repository

    code = params[:code]

    # Update the code in the working copy of the repo.
    @committed = @repository.commit(current_user) do |git|
      path = File.join(@repository.git_path, @filename)
      File.open(path, 'w') { |f| f.write(code) }

      git.add path
    end

    @commit_hash = @repository.commit_hash(@committed[:commit])

    respond_to do |format|
      if @committed
        publish(:code) do
          render_to_string template: 'code/update_code',
            locals: {
              code: code,
              commit: @commit_hash,
              amend: @committed[:amend],
              force: false
            }
        end
      end

      format.js
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
  def hash_change
    code = ''

    @repository.read do |git|
      begin
        code = git.cat_file(git_object)
      rescue
        # Do nothing; an exception will occur if the repository is empty
        # and we want to just ignore that.
      end
    end
    
    respond_to do |format|
      format.js { render template: 'code/update_code',
        locals: { code: code, force: true } }
    end
    
  end


  # -------------------------------------------------------------
  # Called when a new user opens the code controller for a particular
  # repository.
  def add_user
    @repository.connect_user current_user
    users = @repository.connected_users.alphabetical

    code = ''

    @repository.read do |git|
      begin
        code = git.cat_file(git_object)
      rescue
        # Do nothing; an exception will occur if the repository is empty
        # and we want to just ignore that.
      end
    end

    publish(:users) do
      render_to_string template: 'code/update_user_list',
        locals: { users: users }
    end

    respond_to do |format|
      format.js { render template: 'code/update_code',
        locals: { code: code, force: true } }
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

    begin
      code = ''

      @repository.read do
        path = File.join(@repository.git_path, @filename)
        code = File.exists?(path) ? File.read(path) : ''
      end

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
  def check
    @closed = @repository.assignment_offering.closed?
    @was_changed = @repository.changed_since_last_check?

    if !@closed && @was_changed
      assignment_check = @repository.assignment_checks.create(
        number: @repository.next_assignment_check_number)

      CheckCodeWorker.perform_async(assignment_check.id,
        request.headers['X-Session-ID'])
    end

    respond_to do |format|
      format.js { render template: 'code/check' }
    end
  end


  # -------------------------------------------------------------
  def start_over
    begin
      @repository.start_over

      code = ''
      @repository.read do
        path = File.join(@repository.git_path, @filename)
        code = File.exists?(path) ? File.read(path) : ''
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
  def check_results
    assignment_check = AssignmentCheck.find(params[:check])

    respond_to do |format|
      format.js { render template: 'code/check_results',
        locals: { assignment_check: assignment_check } }
    end
  end


  # -------------------------------------------------------------
  def history
    start = params[:start]

    commits = @repository.history(start, 100)

    respond_to do |format|
      format.js { render template: 'code/add_history',
        locals: { commits: commits } }
    end
  end


  # -------------------------------------------------------------
  def publish(channel, &block)
    options = { javascript: block.call }
    Juggernaut.publish @repository.event_channel(channel), options,
      except: request.headers['X-Session-ID']
  end


  # -------------------------------------------------------------
  def find_repository
    parts = @rest ? @rest.split('/') : []

    if parts.first == 'example'
      id = parts.second
      @filename = parts.length > 2 ? File.join(parts[2..-1]) : DEFAULT_FILE

      @repository = ExampleRepository.find_by_id(id)
    elsif parts.first == 'assignments'
      if @term
        # It's a student trying to access their personal repository
        # for an assignment.

        url_part = parts.second
        @filename = parts.length > 2 ? File.join(parts[2..-1]) : DEFAULT_FILE

        assignment = AssignmentOffering.joins(:assignment).where(
          assignments: { url_part: url_part },
          course_offering_id: @offerings.first.id).first

        relation = AssignmentRepository.where(
          user_id: current_user.id,
          assignment_offering_id: assignment.id)

        # Create the repository if it doesn't exist.
        # TODO improve permission checks
        @repository = relation.first || relation.create
      else
        # It's an instructor trying to access the reference repository
        # for an assignment.

        url_part = parts.second
        @filename = parts.length > 2 ? File.join(parts[2..-1]) : DEFAULT_FILE

        assignment = Assignment.where(url_part: url_part).first

        if assignment
          relation = AssignmentReferenceRepository.where(
            assignment_id: assignment.id)

          # Create the repository if it doesn't exist.
          # TODO improve permission checks
          @repository = relation.first

          if @repository.nil? && can?(:edit, assignment)
            @repository = relation.create(user_id: current_user.id)
          end
        end
      end
    end

    # Prevent access to dot-files.
    # TODO maybe allow instructors to do this, though
    parts = @filename ? @filename.split('/') : []
    if (parts.count { |item| item =~ /^\./ }) > 0
      not_found
      return
    end

    # If the path goes to a directory, make sure to append the default file
    # name instead.
    @repository.read do
      path = File.join(@repository.git_path, @filename)
      if File.directory?(path)
        @filename = File.join(@filename, DEFAULT_FILE)
      end
    end

    # Make sure the user has access to read the repository, or raise a
    # not-found exception if it wasn't found.
    if @repository
      authorize! :read, @repository

      @repository.read do |git|
        begin
          @commits = git.gblob(@filename).log(nil).to_a
        rescue
          # If the above fails, it's because the repo doesn't have a
          # HEAD yet (most likely) or it's busted (hopefully not).
          #
          # TODO: We should probably make sure every repository has
          # a HEAD when it's created, by committing a default
          # .gitignore file or something similar.
          @commits = []
        end
      end
    else
      not_found
    end
  end


  # -------------------------------------------------------------
  def sha_param
    params[:sha].blank? ? 'HEAD' : params[:sha]
  end


  # -------------------------------------------------------------
  def git_object
    "#{sha_param}:#{@filename}"
  end

end
