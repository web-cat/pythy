require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @student = users(:test_student)
    @teacher = users(:test_teacher)
    @grader = users(:test_grader)

    @student_ability = Ability.new(@student)
    @teacher_ability = Ability.new(@teacher)
    @grader_ability = Ability.new(@grader)
  end


  test "should find student enrolled in course offering" do
    assert @student.enrolled_course_offerings.
      where(:crn => '98765').exists?
  end

  test "should find teacher staffing course offering" do
    assert @teacher.staffing_course_offerings.
      where(:crn => '98765').exists?
  end

  test "should find grader staffing course offering" do
    assert @grader.staffing_course_offerings.
      where(:crn => '98765').exists?
  end


  # Cancan abilities
  test "should have student able to read enrolled course" do
    assert @student_ability.can?(:read, course_offerings(:cs1064_98765))
  end

  test "should have student unable to read unenrolled course" do
    assert @student_ability.cannot?(:read, course_offerings(:cs1124_12345))
  end

  test "should have student unable to manage enrolled course" do
    assert @student_ability.cannot?(:manage, course_offerings(:cs1064_98765))
  end

  test "should have teacher able to manage staffing course" do
    assert @teacher_ability.can?(:manage, course_offerings(:cs1064_98765))
  end

  test "should have teacher unable to manage non-staffing course" do
    assert @teacher_ability.cannot?(:manage, course_offerings(:cs1124_12345))
  end

end
