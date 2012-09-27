# A join model for the many-to-many relationship between CourseOfferings
# and Users (who are enrolled as students in the course).
#
class CourseOfferingStudent < ActiveRecord::Base

  belongs_to :course_offering
  belongs_to :user

end
