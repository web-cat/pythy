require 'test_helper'

class CourseOfferingTest < ActiveSupport::TestCase

  # -------------------------------------------------------------
  def setup
    @offering = course_offerings(:cs1064_12345)
  end


  # -------------------------------------------------------------
  test "has course enrollment for test student" do
    assert @offering.course_enrollments.where(
      users: { email: 'test_student@vt.edu' }).exists?
  end


  # -------------------------------------------------------------
  test "has course enrollment for test teacher" do
    assert @offering.course_enrollments.where(
      users: { email: 'test_teacher@vt.edu' }).exists?
  end

end
