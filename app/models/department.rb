class Department < ActiveRecord::Base

  belongs_to  :institution
  has_many    :courses

  attr_accessible :abbreviation, :institution_id, :name

end
