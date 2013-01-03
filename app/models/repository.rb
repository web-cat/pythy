class Repository < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id

end
