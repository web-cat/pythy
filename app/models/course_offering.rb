class CourseOffering < ActiveRecord::Base

  ROLE_TEACHER = 1000
  ROLE_TEACHING_ASSISTANT = 2000

  belongs_to  :course
  belongs_to  :term

  has_many    :course_offering_students
  has_many    :students, :through => :course_offering_students,
              :source => :user

  has_many    :course_offering_staff
  has_many    :staff, :through => :course_offering_staff,
              :source => :user

  attr_accessible :course_id, :crn, :label, :term_id, :url

end
