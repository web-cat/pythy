class CourseOffering < ActiveRecord::Base

  belongs_to  :course
  belongs_to  :term

  has_many    :course_enrollments

  attr_accessible :course_id, :crn, :label, :term_id, :url

  validates :term_id, presence: true
  validates :crn, presence: true

end
