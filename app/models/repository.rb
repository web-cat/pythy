class Repository < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id

  validates :user_id, presence: true


  #~ Public methods ...........................................................

  # -------------------------------------------------------------
  # Public: Opens the Git repository corresponding to this Pythy repository
  # object.
  #
  # If a block is given, the Git object is passed to the block, and this
  # method returns the result of the block. Otherwise, this method returns
  # the Git object.
  #
  def open
    @git = Git.open(git_path) unless open?

    if block_given?
      yield @git
    else
      @git
    end
  end


  # -------------------------------------------------------------
  # Public: Returns True if the repository is open, otherwise False.
  #
  def open?
    !@git.nil?
  end


  # -------------------------------------------------------------
  # Public: Locks (TODO) the repository, yields to the passed in block that
  # will perform updates to the repository's working directory, and then
  # commits the changes. The block is passed the Git instance (the underlying
  # repository object) so that it can perform operations on it, such as
  # adding files to the index.
  #
  # The lock used is a Redis-based mutex, so it will properly lock the
  # repository across multiple request processes (or even multiple servers
  # if they all share the same Redis instance).
  #
  # Returns true if the repository changed as a result of the commit.
  #
  def commit(user, message = nil)
    open

    # TODO lock
    
    # Yield to the block, which will manipulate the working directory.
    yield @git

    message ||= "Updated by #{user.display_name}"
    author = "#{user.display_name} <#{user.email}>"

    # Commit the changes, safely ignoring a possible exception if the
    # changes actually resulted in no effective change.
    begin
      @git.add

      amend = should_amend?

      @git.commit_all message, author: author, amend: amend, allow_empty: amend
      commit_result = { amend: amend, commit: @git.log(1).first }

      # Update the updated_at timestamp of the repository with each commit;
      # this allows us to do fast queries/sorting based on last modified
      # time without having to go out to the file system.
      self.touch
    rescue Git::GitExecuteError => e
      # Ignore an exception that says there was nothing to commit; we just
      # silently ignore these. Otherwise, let the exception bubble out.
      if e.message =~ /nothing to commit/
        commit_result = nil
      else
        raise e
      end
    end

    # TODO unlock

    commit_result
  end


  # -------------------------------------------------------------
  # Public: Returns a value indicating whether or not the next commit should
  # amend the previous one, or if it should be a new commit. The default
  # behavior is to amend if the commit came within 1 minute of the previous
  # one. Subclasses can override this to provide their own logic, but they
  # must remember to call super to retain the 1 minute threshold.
  #
  # Returns true if the last commit should be amended, or false to create
  # a new commit.
  def should_amend?
    updated_at >= 1.minute.ago
  end


  # -------------------------------------------------------------
  # Public: Locks (TODO) the repository, yields to the passed in block that
  # will access (read) files in the working directory, and then unlocks the
  # repository. This method should only be used when reading the repository
  # contents; changes should use the `commit` method.
  #
  # The lock used is a Redis-based mutex, so it will properly lock the
  # repository across multiple request processes (or even multiple servers
  # if they all share the same Redis instance).
  #
  def read
    open

    # TODO lock
    
    # Yield to the block, which will access the working directory.
    yield @git

    # TODO unlock
  end


  # -------------------------------------------------------------
  # Public: Locks (TODO) the repository, yields to the passed in block that
  # will modify the repository (for example, create tags), and then unlocks
  # the repository.
  #
  # The lock used is a Redis-based mutex, so it will properly lock the
  # repository across multiple request processes (or even multiple servers
  # if they all share the same Redis instance).
  #
  def write
    open

    # TODO lock
    
    # Yield to the block, which will access the working directory.
    yield @git

    # TODO unlock
  end


  # -------------------------------------------------------------
  def ls(path)
    open
    list = Dir.entries(File.join(git_path, path)).reject { |e| e =~ /^\./ }
  end


  # -------------------------------------------------------------
  # Public: Gets an array of hashes that contain information from the commit
  # log of the repository. The keys included in these hashes by default are:
  #
  #  sha: the SHA of the commit
  #  date: the date of the commit
  #  author: the author of the commit
  #  message: the commit message
  #  commit: the actual Git::Object::Commit object, if more information is
  #      desired
  #
  # If this method is given a block, the block takes a Commit object and is
  # expected to return a hash that will be merged into the hashes in the
  # array. Thus, subclasses can use the following pattern to augment the
  # data in the log:
  #
  #  def history(start, count)
  #    # preprocessing goes here
  #    super do |commit|
  #      { key1: value1, key2: value2, ... }
  #    end
  #  end
  #
  # start - the number of entries in the log to skip
  # count - the number of log entries to retrieve
  #
  # Returns an array of hashes containing the commit log data.
  #
  def history(start, count)
    commits = []

    read do |git|
      git.log(count).skip(start).each do |commit|
        commit_info = commit_hash(commit)
        commit_info.merge!(yield commit) if block_given?
        commits << commit_info
      end
    end

    commits
  end


  # -------------------------------------------------------------
  def commit_hash(commit)
    { commit: commit,
      sha: commit.sha,
      date: commit.date,
      author: commit.author,
      message: commit.message }
  end


  # -------------------------------------------------------------
  # Public: Gets the SHA of the commit that represents the current HEAD of
  # the repository.
  #
  # Returns a String containing the SHA of the repository's HEAD commit.
  #
  def head_sha
    open
    @git.object('HEAD').sha
  end


  # -------------------------------------------------------------
  # Public: Indicates that the specified User has connected to the repository
  # (for example, but opening it in the code view). This is used to provide
  # user tracking, mainly for instructors.
  #
  # user - the User
  #
  def connect_user(user)
    # Add the user ID to the sorted set with a timeout 5 minutes from now.
    # Most users will disconnect on their own when they close the browser
    # window or navigate away, but this will capture situations where a
    # browser might crash.

    added = $redis.zadd(redis_key('accessing_users'),
      5.minutes.from_now.to_i, user.id)

    sync_user user

    # To keep the activity log from ballooning up too much, we're going to
    # assume that a connect that follows within 30 seconds of a disconnect
    # is part of the same "session". This will capture the user refreshing
    # the page, or quick navigation between pages.

    last_disconnect = ActivityLog.where(
      user_id: user.id,
      action: "#{self.class.name.pluralize.underscore}/disconnect",
      created_at: 30.seconds.ago..Time.now).
      order('created_at desc').limit(1).first

    if last_disconnect
      last_disconnect.destroy
    elsif added
      log_activity user, 'connect'
    end
  end


  # -------------------------------------------------------------
  # Public: Indicates that the specified User has disconnected from the
  # repository (for example, but closing that browser tab/window). This is
  # used to provide user tracking, mainly for instructors.
  #
  # user - the User
  #
  def disconnect_user(user)
    $redis.zrem redis_key('accessing_users'), user.id

    log_activity user, 'disconnect'
  end


  # -------------------------------------------------------------
  # Public: Gets a Relation representing the Users that are currently
  # connected to the repository. This is used to provide user tracking,
  # mainly for instructors.
  #
  # Returns a Relation representing the Users currently connected
  #
  def connected_users
    key = redis_key('accessing_users')

    # Since we can only expire top-level keys in Redis and not set/hash
    # elements, we can "fake" this expiration by adding the user IDs to
    # a sorted set where their scores are their absolute expiration time;
    # then whenever we query the currently connected users, we remove the
    # ones with scores less than the current time.
    $redis.zremrangebyscore key, 0, Time.now.to_i

    # Then whatever remains in the set are the user IDs that haven't yet
    # expired.
    User.where(id: $redis.zrange(key, 0, -1))
  end


  # -------------------------------------------------------------
  # Public: Indicates that the specified User has unsynched him/herself
  # from the repository (started typing on his/her own and will stop
  # getting automatic pushes). Currently only used for examples.
  #
  # user - the User
  #
  def unsync_user(user)
    connect_user user

    $redis.setex redis_key("user_unsynched:#{user.id}"),
      5.minutes.from_now.to_i, 1

    log_activity user, 'unsync'
  end


  # -------------------------------------------------------------
  # Public: Indicates that the specified User has re-synched him/herself
  # from the repository and will start getting automatically pushed changes
  # from the instructor. Currently only used for examples.
  #
  # user - the User
  #
  def sync_user(user)
    if $redis.del(redis_key("user_unsynched:#{user.id}")).to_i > 0
      log_activity user, 'sync'
    end
  end


  # -------------------------------------------------------------
  # Public: Gets a Boolean value indicating whether or not the specified
  # User is currently synched with the repository and receiving automatic
  # pushed changes.
  #
  # user - the User
  #
  # Returns true if the User is synched, false if not.
  #
  def user_unsynched?(user)
    $redis.get(redis_key("user_unsynched:#{user.id}")) == '1'
  end


  # -------------------------------------------------------------
  # Public: Gets a Boolean value indicating whether or not the specified User
  # can "check" the repository (that is, executed against reference tests).
  # The default value is false; subclasses should override this method if they
  # can be checked.
  #
  # user - the User
  #  
  # Returns true if the repository can be checked, false if not.
  #
  def can_check?(user)
    false
  end


  # -------------------------------------------------------------
  # Public: Gets a Boolean value indicating whether or not the specified User
  # can sync the repository (pull in the latest version if it differs from
  # their current working copy). The default value is false; subclasses should
  # override this method if they can be checked.
  #
  # user - the User
  #  
  # Returns true if the repository can be synched, false if not.
  #
  def can_sync?(user)
    false
  end


  private

  # -------------------------------------------------------------
  def log_activity(user, action)
    log = ActivityLog.new(user: user,
      action: "#{self.class.name.pluralize.underscore}/#{action}",
      info: { repository: self.id })
    log.save      
  end

end
