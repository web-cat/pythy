class CourseOffering < ActiveRecord::Base

  belongs_to  :course
  belongs_to  :term

  has_many    :example_repositories

  has_many    :course_enrollments, include: [:course_role, :user],
              order: 'course_roles.id asc, users.last_name asc, users.first_name asc'

  has_many    :users, through: :course_enrollments

  attr_accessible :course_id, :crn, :label, :term_id, :url

  validates :term_id, presence: true
  validates :crn, presence: true


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are allowed to
  # manage this CourseOffering.
  #
  # Returns a relation representing all Users who are allowed to manage
  # this CourseOffering.
  #
  def managers
    User.joins(:course_enrollments => :course_role).where(
      course_enrollments: { course_offering_id: id },
      course_roles: { can_manage_course: true })
  end


  # -------------------------------------------------------------
  def other_concurrent_offerings
    course.course_offerings.where('term_id = ? and id != ?', term.id, id)
  end


  # -------------------------------------------------------------
  # Public: Gets the path to the directory where repositories and other
  # resources for this CourseOffering will be stored.
  #
  # Returns the path to the CourseOffering's storage directory.
  def storage_path
    File.join(
      course.department.institution.storage_path,
      term.url_part,
      course.url_part,
      crn.to_s)
  end

end
