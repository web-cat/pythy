class Environment < ActiveRecord::Base

  has_many :courses
  has_many :repositories

  attr_accessible :name, :preamble

  validates :name, presence: true

end
