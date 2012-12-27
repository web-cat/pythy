class CourseRole < ActiveRecord::Base

  attr_accessible :name,
                  :builtin,
                  :can_grade_submissions,
                  :can_manage_assignments,
                  :can_manage_course,
                  :can_view_other_submissions

  validates :name, uniqueness: true

  before_destroy :check_builtin?


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
  def check_builtin?
    errors.add :base, "Cannot delete built-in roles." if builtin?
    errors.blank?
  end

end
