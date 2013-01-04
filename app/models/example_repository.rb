class ExampleRepository < Repository

  belongs_to :course_offering

  belongs_to :source_repository, class_name: 'ExampleRepository'
  has_many :linked_repositories, class_name: 'ExampleRepository',
    foreign_key: 'source_repository_id', dependent: :destroy

  attr_accessible :name, :course_offering_id, :description

  validates :name, presence: true
  validates :course_offering_id, presence: true

  after_create :create_git_repo


  # -------------------------------------------------------------
  def git_path
    if source_repository
      source_repository.git_path
    else
      File.join(
        course_offering.storage_path,
        'examples',
        id.to_s)
    end
  end


  private

  # -------------------------------------------------------------
  def create_git_repo
    # If this ExampleRepository has a source_repository, that means it
    # shouldn't create its own git repo but instead use the one from
    # the source (it's a shadow of another repository shared across
    # multiple offerings).
    #
    # TODO We could consider creating a soft-link in this case, but for
    # now we'll just have the git_path method recursively return the
    # source repo's path instead.

    unless source_repository
      path = git_path

      unless File.exists?(path)
        FileUtils.mkdir_p path
        Git.init(path)
      end
    end
  end

end
