require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  
  # Tests that the department_name_and_number method returns the correct
  # string.
  test "department name and number" do
  	course = courses(:cs1064)
    assert_equal "CS 1064", course.department_name_and_number
  end

end
