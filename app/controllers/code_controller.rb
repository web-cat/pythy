class CodeController < FriendlyUrlController

  DEFAULT_FILE = 'main.py'

  before_filter :find_repository


  # -------------------------------------------------------------
  def edit
  end


  # -------------------------------------------------------------
  def update
    code = params[:code]

    # Update the code in the working copy of the repo.
    path = File.join(@repository.git_path, @filename)
    File.open(path, 'w') { |f| f.write(code) }

    git = @repository.open
    git.add path

    begin
      git.commit_all "Updated by #{current_user.display_name}",
        author: "#{current_user.display_name} <#{current_user.email}>"
    rescue Git::GitExecuteError => e
      raise e unless e.message =~ /nothing to commit/
    end

    respond_to do |format|
      format.js
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
