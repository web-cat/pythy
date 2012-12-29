class CourseEnrollment < ActiveRecord::Base
  belongs_to :user
  belongs_to :course_offering
  belongs_to :course_role
  
  attr_accessible :user, :course_offering, :course_role, :user_id,
    :course_offering_id, :course_role_id


  SQL_HAS_ANY_PERMISSIONS = <<-SQL
    `course_roles`.`can_manage_course`          = 1 or
    `course_roles`.`can_manage_assignments`     = 1 or
    `course_roles`.`can_grade_submissions`      = 1 or
    `course_roles`.`can_view_other_submissions` = 1
  SQL

  SQL_HAS_NO_PERMISSIONS = <<-SQL
    `course_roles`.`can_manage_course`          = 0 and
    `course_roles`.`can_manage_assignments`     = 0 and
    `course_roles`.`can_grade_submissions`      = 0 and
    `course_roles`.`can_view_other_submissions` = 0
  SQL


  scope :staff, joins(:course_role).where(SQL_HAS_ANY_PERMISSIONS)
  scope :students, joins(:course_role).where(SQL_HAS_NO_PERMISSIONS)

end
