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
      @git.commit_all message, author: author
      committed = true

      # Update the updated_at timestamp of the repository with each commit;
      # this allows us to do fast queries/sorting based on last modified
      # time without having to go out to the file system.
      self.touch
    rescue Git::GitExecuteError => e
      # Ignore an exception that says there was nothing to commit; we just
      # silently ignore these. Otherwise, let the exception bubble out.
      if e.message =~ /nothing to commit/
        committed = false
      else
        raise e
      end
    end

    # TODO unlock

    committed
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
    # TODO lock
    
    # Yield to the block, which will access the working directory.
    yield

    # TODO unlock
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


  private

  # -------------------------------------------------------------
  def log_activity(user, action)
    log = ActivityLog.new(user: user,
      action: "#{self.class.name.pluralize.underscore}/#{action}",
      info: { repository: self.id })
    log.save      
  end

end
