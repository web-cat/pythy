class Repository < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id

  validates :user_id, presence: true


  #~ Public methods ...........................................................

  # -------------------------------------------------------------
  # Public: Opens the Git repository corresponding to this Pythy repository
  # object.
  #
  # Returns the Git repository.
  #
  def open
    Git.open(git_path)
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
