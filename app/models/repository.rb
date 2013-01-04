class Repository < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id

  validates :user_id, presence: true


  # -------------------------------------------------------------
  def open
    Git.open(git_path)
  end

end
