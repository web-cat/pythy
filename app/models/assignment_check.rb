class AssignmentCheck < ActiveRecord::Base

  COMPLETED = 1
  TIMEOUT = 2
  FAILED = 3

  belongs_to :assignment_repository
  has_many :check_outcomes

  attr_accessible :assignment_repository_id, :number,
    :status, :overall_score, :extra, :commit_sha

  serialize :extra, Hash

  before_create :store_commit_sha
  after_create :create_git_tag


  # -------------------------------------------------------------
  def self.completed
    where(status: COMPLETED)
  end


  # -------------------------------------------------------------
  def self.timed_out
    where(status: TIMEOUT)
  end


  # -------------------------------------------------------------
  # Public: Gets the `count` most recent AssignmentChecks. This is mostly
  # meant to be chained to an AssignmentRepository, to get the most recent
  # check, like so:
  #
  #   some_repository.assignment_checks.most_recent  # or
  #   some_repository.assignment_checks.completed.most_recent
  #
  # If this method is given a parameter, then it returns a Relation
  # representing the `count` most recent checks. If nothing (or nil) is
  # passed, then it returns the single AssignmentCheck object, or nil if
  # there are no checks.
  #
  def self.most_recent(count = nil)
    if count.nil?
      order('updated_at desc').limit(1).first
    else
      order('updated_at desc').limit(count)
    end
  end


  # -------------------------------------------------------------
  # Public: Gets the Git tag that denotes this check attempt.
  #
  # Returns a String containing the Git tag name for this attempt.
  #
  def git_tag
    "check/#{number}"
  end


  private

  # -------------------------------------------------------------
  def store_commit_sha
    assignment_repository.read do |git|
      self.commit_sha = git.object('HEAD').sha
    end
  end


  # -------------------------------------------------------------
  # Private: Tags the current HEAD of the repository with a tag that denotes
  # this check attempt, and records the SHA of the HEAD in the database.
  #
  def create_git_tag
    assignment_repository.write do |git|
      git.add_tag git_tag
    end
  end

end
