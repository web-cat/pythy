class Project < ActiveRecord::Base
  belongs_to :assignment
  attr_accessible :name
end
