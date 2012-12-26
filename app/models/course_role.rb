class CourseRole < ActiveRecord::Base
  attr_accessible :builtin,
                  :can_grade_submissions,
                  :can_manage_assignments,
                  :can_manage_course,
                  :can_view_other_submissions,
                  :name

  validates_uniqueness_of :name

  before_destroy :check_builtin?

  def check_builtin?
    errors.add :base, "Cannot delete built-in roles." if builtin?
    errors.blank?
  end
end
