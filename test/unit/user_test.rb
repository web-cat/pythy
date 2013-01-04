require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # -------------------------------------------------------------
  def setup
    @student = users(:test_student)
    @teacher = users(:test_teacher)
    @grader = users(:test_grader)

    @student_ability = Ability.new(@student)
    @teacher_ability = Ability.new(@teacher)
    @grader_ability = Ability.new(@grader)
  end


  # -------------------------------------------------------------
  test "should find student enrolled in course offering" do
    assert @student.course_offerings.where(crn: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should not find student managing course offering" do
    assert !@student.managing_course_offerings.where(crn: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should find teacher enrolled in course offering" do
    assert @teacher.course_offerings.where(crn: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should find teacher managing course offering" do
    assert @teacher.managing_course_offerings.where(crn: '12345').exists?
  end


  # Cancan abilities

  # -------------------------------------------------------------
  test "should have student able to read enrolled course" do
    assert @student_ability.can?(:read, course_offerings(:cs1064_12345))
  end


  # -------------------------------------------------------------
  test "should have student unable to read unenrolled course" do
    assert @student_ability.cannot?(:read, course_offerings(:cs1064_12346))
  end


  # -------------------------------------------------------------
  test "should have student unable to manage enrolled course" do
    assert @student_ability.cannot?(:manage, course_offerings(:cs1064_12345))
  end


  # -------------------------------------------------------------
  test "should have teacher able to manage staffing course" do
    assert @teacher_ability.can?(:manage, course_offerings(:cs1064_12345))
  end


  # -------------------------------------------------------------
  test "should have teacher unable to manage non-staffing course" do
    assert @teacher_ability.cannot?(:manage, course_offerings(:cs1064_12346))
  end

end
