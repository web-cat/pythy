class AssignmentRepository < Repository

  belongs_to :assignment_offering
  has_many :assignment_checks

  after_create :create_git_repo


  # -------------------------------------------------------------
  def environment
    read_attribute(:environment) ||
      assignment_offering.course_offering.course.default_environment
  end


  # -------------------------------------------------------------
  # Public: Gets the path to the root of the repository's storage area. This
  # folder has two subfolders: 'code', which is the location of the actual
  # Git repository holding the student's code (that is, .../code/.git), and
  # 'results', which holds information about the student's attempted checks
  # against the reference tests.
  #
  def root_path
    File.join(
      assignment_offering.course_offering.storage_path,
      'assignments',
      assignment_offering.assignment.url_part,
      user.email)
  end


  # -------------------------------------------------------------
  def git_path
    File.join(root_path, 'code')
  end


  # -------------------------------------------------------------
  def results_path
    File.join(root_path, 'results')
  end


  # -------------------------------------------------------------
  # Public: Returns a value indicating whether or not the next commit should
  # amend the previous one, or if it should be a new commit. This subclass
  # retains the 1 minute threshold of the superclass, but also adds the
  # condition that a commit that is associated with a check should never be
  # amended.
  #
  # Returns true if the last commit should be amended, or false to create
  # a new commit.
  def should_amend?
    check = assignment_checks.most_recent
    if check
      super && check.commit_sha != head_sha
    else
      super
    end
  end


  # -------------------------------------------------------------
  def history(start, count)
    checks = assignment_checks.index_by(&:commit_sha)

    super do |commit|
      { assignment_check: checks[commit.sha] }
    end
  end


  # -------------------------------------------------------------
  def can_check?(user)
    true
  end


  # -------------------------------------------------------------
  def warn_if_not_owner?
    true
  end


  # -------------------------------------------------------------
  def changed_since_last_check?
    most_recent = assignment_checks.most_recent

    if most_recent
      open do |git|
        most_recent_sha = git.object(most_recent.git_tag).sha
        head_sha = git.object('HEAD').sha

        most_recent_sha != head_sha
      end
    else
      true
    end
  end


  # -------------------------------------------------------------
  def next_assignment_check_number
    last_check = assignment_checks.where('number is not null').
      order('number desc').limit(1).select(:number).first
    last_number = last_check ? last_check.number + 1 : 1
  end


  # -------------------------------------------------------------
  def start_over
    commit(user, 'Started over.') do |git|
      Dir.entries(git_path) do |entry|
        if entry !~ /\./
          FileUtils.rm_r File.join(git_path, entry)
        end
      end

      copy_starter_files
      git.add '.'
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
        copy_starter_files
        git.add '.'
      end
    end
  end


  # -------------------------------------------------------------
  def copy_starter_files
    ref_repo = assignment_offering.assignment.assignment_reference_repository
    ref_repo.copy_starter_files_to git_path
  end

end
