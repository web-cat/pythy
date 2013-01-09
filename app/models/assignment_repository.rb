class AssignmentRepository < Repository

  belongs_to :assignment_offering

  after_create :create_git_repo


  # -------------------------------------------------------------
  def git_path
    File.join(
      assignment_offering.course_offering.storage_path,
      'assignments',
      assignment_offering.assignment.url_part,
      user.email)
  end


  private

  # -------------------------------------------------------------
  def create_git_repo
    path = git_path

    unless File.exists?(path)
      FileUtils.mkdir_p path
      Git.init(path)
    end
  end

end
