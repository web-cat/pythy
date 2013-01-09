class AssignmentOffering < ActiveRecord::Base

  belongs_to  :assignment
  belongs_to  :course_offering

  accepts_nested_attributes_for :assignment

  attr_accessible :assignment_id, :assignment_attributes,
    :course_offering_id, :opens_at, :closes_at, :due_at


  # -------------------------------------------------------------
  def self.visible
    where('opens_at is not null && opens_at <= ?', Time.now)
  end


  # -------------------------------------------------------------
  def visible?
    opens_at && Time.now >= opens_at
  end


  # -------------------------------------------------------------
  def past_due?
    effectively_due_at < Time.now
  end


  # -------------------------------------------------------------
  def effectively_due_at
    due_at || closes_at
  end

end
