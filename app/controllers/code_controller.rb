require 'redis'

class CodeController < FriendlyUrlController
  include FriendlyUrlHelper

  layout 'code'

  DEFAULT_FILE = 'main.py'

  ALLOWED_MESSAGES = %w(hash_change add_user remove_user unsync resync
    ping check start_over check_results history prompt_for_environment)

  before_filter :authenticate_user!
  before_filter :find_repository

  # -------------------------------------------------------------
  def show
    if @needs_redirect
      puts("\n\nDEBUG ------------v\n" + @repository.inspect + "\n\n")
      redirect_to staff_code_url(@repository)
    else
      @subscribe_channel = @repository.event_channel(nil)

      @repository.read do
        path = File.join(@repository.git_path, @filename)
        FileUtils.touch path unless File.exists?(path)
      end

      if @repository.is_a? AssignmentRepository
        a = @repository.assignment_offering.assignment
        @page_title = "#{a.course.number} &ndash; #{a.short_name}: #{a.long_name}"
      elsif @repository.is_a? AssignmentReferenceRepository
        a = @repository.assignment
        @page_title = "#{a.course.number} &ndash; #{a.short_name}: #{a.long_name}"
      elsif @repository.is_a? ExampleRepository
        @page_title = "#{@repository.course_offering.course.number} &ndash; Example: #{@repository.name}"
      elsif @repository.is_a? ScratchpadRepository
        @page_title = "#{@repository.user.display_name} &ndash; Scratchpad"
      end

      if @repository.warn_if_not_owner? && @repository.user != current_user
        flash[:alert] = "You are viewing a repository that belongs to #{@repository.user.display_name}."
      end

      @code_area_data = {
        :channel => @subscribe_channel,
        :editor => can?(:update, @repository),
        :'user-media-key' => current_user.resource_key
      }

      if @repository.is_a? ScratchpadRepository
        @code_area_data[:'needs-environment'] = !@repository.environment_present?
      end
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

    respond_to do |format|
      if @committed
        @commit_hash = @repository.commit_hash(@committed[:commit])
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
      format.js {
        render template: 'code/update_code',
          locals: {
            code: code,
            environment: @repository.environment,
            force: true
          }
      }
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
  def prompt_for_environment
    env = @repository.read_attribute(:environment_id)

    respond_to do |format|
      format.js {
        render template: 'code/prompt_for_environment',
          locals: {
            update_url: polymorphic_path(@repository),
            model_name: @repository.class.name.underscore,
            environment_id: env
          }
      }
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
  def find_example_repository_from_path_parts(parts)
    parts.shift
    id = parts.shift

    @repository = ExampleRepository.find_by_id(id)
  end


  # -------------------------------------------------------------
  def find_assignment_repository_from_path_parts(parts)
    parts.shift

    if @term
      # It's a student trying to access their personal repository
      # for an assignment.

      url_part = parts.shift

      assignment = AssignmentOffering.joins(:assignment).where(
        assignments: { url_part: url_part },
        course_offering_id: @offerings.first.id).first

      relation = AssignmentRepository.where(
        user_id: current_user.id,
        assignment_offering_id: assignment.id)

      # Create the repository if it doesn't exist.
      # TODO improve permission checks
      # @repository = relation.first || relation.create
      @repository = relation.first
      if !@repository
        @repository = relation.create
        @repository.create_git_repo
      end
    else
      # It's an instructor trying to access the reference repository
      # for an assignment.

      url_part = parts.shift

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


  # -------------------------------------------------------------
  def find_scratchpad_repository_from_path_parts(parts)
    @repository = current_user.scratchpad_repository ||
      current_user.create_scratchpad_repository
  end


  # -------------------------------------------------------------
  def find_student_repository_from_path_parts(parts)
    # Course staff trying to access another student's repository for
    # an assignment.

    user_id = parts.shift.to_i
    url_part = parts.shift

    assignment = AssignmentOffering.joins(:assignment).where(
      assignments: { url_part: url_part },
      course_offering_id: @offerings.first.id).first

    relation = AssignmentRepository.where(
      user_id: user_id,
      assignment_offering_id: assignment.id)

    # TODO improve permission checks
    @repository = relation.first
  end


  # -------------------------------------------------------------
  def find_repository
    parts = @rest ? @rest.split('/') : []

    case parts.first
    when /^\d+$/
      @repository = Repository.where(:assignment_offering_id => parts[1].to_i, :user_id => parts.first).first
      parts = []
    when 'example'
      find_example_repository_from_path_parts(parts)
    when 'assignments'
      find_assignment_repository_from_path_parts(parts)
    when 'scratchpad'
      find_scratchpad_repository_from_path_parts(parts)
    else
      find_student_repository_from_path_parts(parts)
    end

    @filename = parts.length > 0 ? File.join(parts) : DEFAULT_FILE

    # Prevent access to dot-files.
    # TODO maybe allow instructors to do this, though
    parts = @filename ? @filename.split('/') : []
    if (parts.count { |item| item =~ /^\./ }) > 0
      not_found
      return
    end

    if @repository
      # Make sure the user has access to read the repository, or raise a
      # not-found exception if it wasn't found.
      authorize! :read, @repository

      # If the path goes to a directory, make sure to append the default file
      # name instead.
      @repository.read do |git|
        path = File.join(@repository.git_path, @filename)
        if File.directory?(path)
          @filename = File.join(@filename, DEFAULT_FILE)
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
