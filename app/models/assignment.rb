class Assignment < ActiveRecord::Base

  belongs_to  :creator, class_name: "User"
  belongs_to  :course

  has_many    :assignment_offerings

  attr_accessible :creator_id, :long_name, :short_name, :description,
    :assignment_offerings_attributes

  accepts_nested_attributes_for :assignment_offerings

  validates :short_name, presence: true
  validates :long_name, presence: true

  before_validation :set_url_part


  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(short_name)
  end

end
