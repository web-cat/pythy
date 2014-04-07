# =============================================================================
# Public: Represents logged activity by a user in the system. Activities that
# are logged include session creation/destruction (i.e., sign-in and sign-out),
# 
class ActivityLog < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user, :action, :info

  serialize :info, Hash

  default_scope -> { includes(:user).order('activity_logs.created_at desc') }

  validates :action, presence: true
  validates :user, presence: true

  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  # Public: Gets all of the actions currently in the activity_log table.
  # Mainly used for populating typeahead fields in filter forms.
  #
  # prefix - the prefix to filter action names by
  #
  # Returns an Array containing all of the action names that start with
  # the prefix, sorted in ascending order.
  #
  def self.all_actions(prefix = '')
    self.uniq
      .where(self.arel_table[:action].matches("#{prefix}%"))
      .reorder('action asc')
      .pluck(:action)
  end

end
