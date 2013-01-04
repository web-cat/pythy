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


  test "has correct concurrent offerings" do
    concurrent = @offering.other_concurrent_offerings
    concurrent.inspect
    assert_equal 1, concurrent.count
    assert_equal course_offerings(:cs1064_12346), concurrent.first
  end

end
