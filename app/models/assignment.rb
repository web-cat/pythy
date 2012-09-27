class Assignment < ActiveRecord::Base

  belongs_to  :creator, :class_name => "User"
  has_many    :assignment_offerings

  attr_accessible :creator_id, :long_name, :short_name

end
