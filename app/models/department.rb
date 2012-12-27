class Department < ActiveRecord::Base

  belongs_to  :institution

  has_many    :courses

  attr_accessible :abbreviation, :institution_id, :name

  before_validation :set_url_part


  #~ Validation ...............................................................

  validates :name, presence: true

  validates :abbreviation, presence: true


  #~ Instance methods .........................................................

  private

  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(abbreviation)
  end

end
