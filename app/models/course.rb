#
# A course represents a course (which may have multiple sections; see
# course_offering.rb) in a department, such as "CS 1064".
#
class Course < ActiveRecord::Base
  
  # Relationships
  belongs_to  :department
  has_many    :assignments

  attr_accessible :department_id, :name, :number

  # Helper methods

  # Gets a string representing the short name of the course using its
  # department name and course number. For example, "CS 1064".
  #
  def department_name_and_number
  	"#{department.abbreviation} #{number}"
  end

end
