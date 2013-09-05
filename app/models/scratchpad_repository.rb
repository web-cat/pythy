class ScratchpadRepository < Repository

  belongs_to :user

  after_create :create_git_repo


  # -------------------------------------------------------------
  def environment
    # FIXME the second clause should use a system default environment
    attribute_present?(:environment_id) && super || Environment.all.first
  end


  # -------------------------------------------------------------
  def environment_present?
    attribute_present?(:environment_id)
  end


  # -------------------------------------------------------------
  # Public: Gets the path to the root of the repository's storage area.
  #
  def git_path
    File.join(
      user.storage_path,
      'repositories',
      'scratchpad')
  end


  private

  # -------------------------------------------------------------
  def create_git_repo
    path = git_path

    unless File.exists?(path)
      FileUtils.mkdir_p path
      
      old_path = Dir.pwd
      Dir.chdir(path)
      Git.init
      Dir.chdir(old_path)

      commit(user, 'Initial repository setup.') do |git|
        FileUtils.touch File.join(path, 'main.py')
        git.add '.'
      end
    end
  end


  # -------------------------------------------------------------
  def create_dir(dirname)
    dirpath = File.join(git_path, dirname)
    FileUtils.mkdir_p dirpath
    FileUtils.touch File.join(dirpath, '.gitkeep')
  end

end
