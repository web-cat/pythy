class CourseRole < ActiveRecord::Base
  attr_accessible :builtin, :can_grade_submissions, :can_manage_assignments, :can_manage_course, :can_manage_course, :can_view_other_submissions, :name
end
