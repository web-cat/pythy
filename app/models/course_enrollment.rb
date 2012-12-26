class CourseEnrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_offering
  belongs_to :course_role
  
  attr_accessible :user, :course_offering, :course_role, :user_id, :course_offering_id, :course_role_id
end
