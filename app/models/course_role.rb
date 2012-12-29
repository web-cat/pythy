class CourseRole < ActiveRecord::Base

  attr_accessible :name,
                  :builtin,
                  :can_manage_course,
                  :can_manage_assignments,
                  :can_grade_submissions,
                  :can_view_other_submissions

  validates :name, presence: true, uniqueness: true
  
  with_options if: :builtin?, on: :update, changeable: false do |builtin|
    builtin.validates :can_manage_course
    builtin.validates :can_manage_assignments
    builtin.validates :can_grade_submissions
    builtin.validates :can_view_other_submissions
  end

  before_destroy :check_builtin?


  SQL_HAS_ANY_PERMISSIONS = <<-SQL
    `can_manage_course`          = 1 or
    `can_manage_assignments`     = 1 or
    `can_grade_submissions`      = 1 or
    `can_view_other_submissions` = 1
  SQL

  SQL_HAS_NO_PERMISSIONS = <<-SQL
    `can_manage_course`          = 0 and
    `can_manage_assignments`     = 0 and
    `can_grade_submissions`      = 0 and
    `can_view_other_submissions` = 0
  SQL

  scope :elevated, where(SQL_HAS_ANY_PERMISSIONS)
  scope :unelevated, where(SQL_HAS_NO_PERMISSIONS)


  # Make sure to run rake db:seed after initial database creation
  # to ensure that the built-in roles with these IDs are created.
  # These IDs should not be referred to directly in most cases;
  # use the class methods below to fetch the actual role object
  # instead.
  LEAD_INSTRUCTOR_ID = 1
  INSTRUCTOR_ID      = 2
  GRADER_ID          = 3
  STUDENT_ID         = 4


  #~ Class methods ............................................................

  # -------------------------------------------------------------
  def self.lead_instructor
    find(LEAD_INSTRUCTOR_ID)
  end


  # -------------------------------------------------------------
  def self.instructor
    find(INSTRUCTOR_ID)
  end


  # -------------------------------------------------------------
  def self.grader
    find(GRADER_ID)
  end


  # -------------------------------------------------------------
  def self.student
    find(STUDENT_ID)
  end


  #~ Instance methods .........................................................

  # -------------------------------------------------------------
  def elevated?
    can_manage_course || can_manage_assignments ||
      can_grade_submissions || can_view_other_submissions
  end


  private

  # -------------------------------------------------------------
  def check_builtin?
    errors.add :base, "Cannot delete built-in roles." if builtin?
    errors.blank?
  end

end
