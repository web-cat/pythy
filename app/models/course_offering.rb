class CourseOffering < ActiveRecord::Base

  belongs_to  :course
  belongs_to  :term

  has_many    :example_repositories
  has_many    :assignment_offerings

  has_many    :course_enrollments,
    -> { CourseEnrollment.includes(:course_role, :user)
      .order('course_roles.id ASC', 'users.full_name ASC') }

  validates :term_id, presence: true
  validates :short_label, presence: true
  
  attr_accessible :course_id, :short_label, :long_label, :term_id,
                  :url, :self_enrollment_allowed

  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are associated
  # with this CourseOffering.
  #
  def users
    User.includes(course_enrollments: :course_role).where(
      course_enrollments: { course_offering_id: id })
      .order('course_roles.id ASC', 'users.full_name ASC')
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are allowed to
  # manage this CourseOffering.
  #
  def managers
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: { course_offering_id: id },
      course_roles: { can_manage_course: true })
  end


  # -------------------------------------------------------------
  # Public: Gets a relation representing all Users who are students in
  # this CourseOffering.
  #
  def students
    User.joins(course_enrollments: :course_role).where(
      course_enrollments: {
        course_offering_id: id,
        course_role_id: CourseRole.student
      })
  end


  # -------------------------------------------------------------
  def full_label
    if long_label.blank?
      short_label
    else
      "#{short_label} (#{long_label})"
    end
  end


  # -------------------------------------------------------------
  def users_sorted_by_role(options = {})
    result = course_enrollments.sort do |a, b|
      aon = a.course_role.order_number
      bon = b.course_role.order_number

      if aon != bon
        aon <=> bon
      else
        a.user.full_name <=> b.user.full_name
      end
    end

    if options[:reversed]
      result.map(&:user).reverse
    else
      result.map(&:user)
    end
  end


  # -------------------------------------------------------------
  def other_concurrent_offerings
    course.course_offerings.where('term_id = ? and id != ?', term.id, id)
  end


  # -------------------------------------------------------------
  def user_enrolled?(user)
    course_enrollments.where(user_id: user.id).any?
  end


  # -------------------------------------------------------------
  def role_for_user(user)
    enrollment = course_enrollments.where(user_id: user.id).first
    enrollment ? enrollment.course_role : nil
  end


  # -------------------------------------------------------------
  # Public: Gets the path to the directory where repositories and other
  # resources for this CourseOffering will be stored.
  #
  # Returns the path to the CourseOffering's storage directory.
  def storage_path
    File.join(
      course.organization.storage_path,
      course.url_part,
      term.url_part,
      short_label)
  end

end
