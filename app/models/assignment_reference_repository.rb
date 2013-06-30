# =========================================================================
# An instructor's reference repository for an assignment. Can contain a sample
# solution, starter files for students, and reference tests.
#
class AssignmentReferenceRepository < Repository

  belongs_to :assignment

  attr_accessible :assignment_id

  after_create :create_git_repo


  # -------------------------------------------------------------
  def environment
    read_attribute(:environment) || assignment.course.default_environment
  end


  # -------------------------------------------------------------
  # Public: Gets the path to the root of the repository's storage area.
  #
  def git_path
    File.join(
      assignment.course.storage_path,
      'assignments',
      assignment.url_part)
  end


  # -------------------------------------------------------------
  def copy_starter_files_to(dir)
    read do
      starter_dir = File.join(git_path, 'starter')

      if File.directory?(starter_dir)
        FileUtils.cp_r "#{starter_dir}/.", dir
      end
    end
  end


  private

  # -------------------------------------------------------------
  def create_git_repo
    path = git_path

    unless File.exists?(path)
      FileUtils.mkdir_p path
      Git.init(path)

      commit(user, 'Initial repository setup.') do |git|
        # Touch the main solution file.
        FileUtils.touch File.join(path, 'main.py')

        # An area to store additional Python modules that should be loaded
        # when the program runs. (TODO)
        create_dir 'lib'

        # An area to store Python modules containing reference tests.
        create_dir 'test', %w(test.py)

        # An area to store assets/resources that students should have
        # access to when their program is running (e.g., text files with
        # data they need to read, or images).
        create_dir 'assets'

        # An area to store documentation (TODO may be used in the future
        # to store the assignment write-ups instead of putting it in the
        # database).
        create_dir 'doc'

        # An area to store starter files that will be cloned into the
        # student's new repository when they start working on an assignment.
        create_dir 'starter', %w(main.py)

        git.add '.'
      end
    end
  end


  # -------------------------------------------------------------
  def create_dir(dirname, files=[])
    dirpath = File.join(git_path, dirname)
    FileUtils.mkdir_p dirpath
    FileUtils.touch File.join(dirpath, '.gitkeep')

    files.each do |file|
      FileUtils.touch File.join(dirpath, file)
    end
  end

end
