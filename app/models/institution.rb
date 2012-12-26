class Institution < ActiveRecord::Base

  has_many    :departments
  has_many    :users

  attr_accessible :display_name, :domain, :abbreviation

  validates :abbreviation, uniqueness: { case_sensitive: false }
  validates :domain, uniqueness: { case_sensitive: false }

end
