class Institution < ActiveRecord::Base

  has_many    :departments
  has_many    :users

  attr_accessible :display_name, :domain

end
