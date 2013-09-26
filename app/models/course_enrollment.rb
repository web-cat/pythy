class CourseEnrollment < ActiveRecord::Base

  belongs_to :user
  belongs_to :course_offering
  belongs_to :course_role

  paginates_per 100
  
  attr_accessible :user, :course_offering, :course_role, :user_id,
                  :course_offering_id, :course_role_id

end
