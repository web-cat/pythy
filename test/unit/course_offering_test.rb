require 'test_helper'

class CourseOfferingTest < ActiveSupport::TestCase

  def setup
    @offering = course_offerings(:cs1064_98765)
  end


  test "has student enrolled" do
  	assert @offering.students.where(:username => 'test_student').exists?
  end

  test "has teacher as staff" do
  	assert @offering.staff.where(:username => 'test_teacher').exists?
  end

  test "has grader as staff" do
    assert @offering.staff.where(:username => 'test_grader').exists?
  end

end
