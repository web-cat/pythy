class AssignmentOffering < ActiveRecord::Base

  belongs_to  :assignment
  belongs_to  :course_offering

  attr_accessible :assignment_id, :course_offering_id, :opens_at, :closes_at, :due_at

end
