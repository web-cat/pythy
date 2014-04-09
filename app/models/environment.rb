class Environment < ActiveRecord::Base

  has_many :courses, foreign_key: 'default_environment_id'
  has_many :repositories

  attr_accessible :name, :preamble

  validates :name, presence: true

end
