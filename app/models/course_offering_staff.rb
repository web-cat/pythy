# A join model for the many-to-many relationship between CourseOfferings
# and Users (who are staff for the course, meaning that they can create
# update, and delete assignments in that course).
#
class CourseOfferingStaff < ActiveRecord::Base

  belongs_to :course_offering
  belongs_to :user

  attr_accessible :course_offering_id, :user_id, :manager, :title

end
