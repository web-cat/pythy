require 'test_helper'

class AbilityTest < ActiveSupport::TestCase

  # -------------------------------------------------------------
  def setup
    @student = users(:test_student)
    @teacher = users(:test_teacher)
    @grader = users(:test_grader)

    @student_ability = Ability.new(@student)
    @teacher_ability = Ability.new(@teacher)
    @grader_ability = Ability.new(@grader)
  end


  # Course Offerings

  # -------------------------------------------------------------
  test "should have student able to read nrolled course" do
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


  # Repositories

  # -------------------------------------------------------------
  test "should have student able to read example repository in enrolled course" do
    assert @student_ability.can?(:read, repositories(:example_in_12345))
  end


  # -------------------------------------------------------------
  test "should have student unable to manage example repository in enrolled course" do
    assert @student_ability.cannot?(:manage, repositories(:example_in_12345))
  end


  # -------------------------------------------------------------
  test "should have student unable to read example repository in unenrolled course" do
    assert @student_ability.cannot?(:read, repositories(:example_in_12346))
  end


  # -------------------------------------------------------------
  test "should have teacher able to manage example repository in enrolled course" do
    assert @teacher_ability.can?(:manage, repositories(:example_in_12345))
  end


  # -------------------------------------------------------------
  test "should have teacher unable to manage example repository in unenrolled course" do
    assert @teacher_ability.cannot?(:manage, repositories(:example_in_12346))
  end


end
