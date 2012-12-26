class ActivityLog < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user, :action, :info

  serialize :info, Hash

  default_scope includes(:user).order('activity_logs.created_at desc')


  # -------------------------------------------------------------
  def self.all_actions(prefix = '')
    self.uniq.where(self.arel_table[:action].matches(
      "#{prefix}%")).reorder('action asc').pluck(:action)
  end

end
