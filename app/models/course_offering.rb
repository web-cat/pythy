class CourseOffering < ActiveRecord::Base

  belongs_to  :course
  belongs_to  :term

  has_many    :example_repositories
  has_many    :course_enrollments, include: [:course_role, :user],
              order: 'course_roles.id asc, users.last_name asc, users.first_name asc'
  has_many    :users, through: :course_enrollments do
    def staff
      joins('INNER JOIN `course_roles` ON `course_enrollments`.`course_role_id` = `course_roles`.`id`').
      where(CourseEnrollment::SQL_HAS_ANY_PERMISSIONS)
    end

    def students
      joins('INNER JOIN `course_roles` ON `course_enrollments`.`course_role_id` = `course_roles`.`id`').
      where(CourseEnrollment::SQL_HAS_NO_PERMISSIONS)
    end
  end

  attr_accessible :course_id, :crn, :label, :term_id, :url

  validates :term_id, presence: true
  validates :crn, presence: true


  # -------------------------------------------------------------
  # Public: Gets the CourseEnrollments for all users associated with the
  # course offering who have a role that qualifies them as "staff" (that
  # is, any user who has at least one elevated permission).
  #
  # Returns a relation representing CourseEnrollments for all staff users
  # in the course offering.
  #
  def staff_enrollments
    course_enrollments.staff
  end


  # -------------------------------------------------------------
  # Public: Gets all staff Users in the course offering. This is a shortcut
  # (and faster, SQL-wise) for retrieving the `staff_enrollments` relation
  # and then retrieving the User from each of those.
  #
  # Returns a relation representing all staff Users in the course offering.
  #
  def staff
    users.staff
  end


  # -------------------------------------------------------------
  # Public: Gets the CourseEnrollments for all users associated with the
  # course offering who have a role that qualifies them as "student" (that
  # is, any user who has no elevated permissions).
  #
  # Returns a relation representing CourseEnrollments for all student
  # users in the course offering.
  #
  def student_enrollments
    course_enrollments.students
  end


  # -------------------------------------------------------------
  # Public: Gets all student Users in the course offering. This is a shortcut
  # (and faster, SQL-wise) for retrieving the `student_enrollments` relation
  # and then retrieving the User from each of those.
  #
  # Returns a relation representing all student Users in the course offering.
  #
  def students
    users.students
  end


  # -------------------------------------------------------------
  def storage_path
    File.join(
      course.department.institution.storage_path,
      term.url_part,
      course.url_part,
      crn.to_s)
  end

end
