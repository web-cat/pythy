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
    assert @student.course_offerings.where(short_label: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should not find student managing course offering" do
    assert !@student.managing_course_offerings.where(short_label: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should find teacher enrolled in course offering" do
    assert @teacher.course_offerings.where(short_label: '12345').exists?
  end


  # -------------------------------------------------------------
  test "should find teacher managing course offering" do
    assert @teacher.managing_course_offerings.where(short_label: '12345').exists?
  end

end
