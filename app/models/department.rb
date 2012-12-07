class Department < ActiveRecord::Base

  belongs_to  :institution
  has_many    :courses

  validates :name, presence: true
  validates :abbreviation, presence: true

  attr_accessible :abbreviation, :institution_id, :name

end
