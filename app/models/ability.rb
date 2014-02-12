# =============================================================================
# The Ability class is used by CanCan to control how users with various roles
# can access resources in Pythy.
#
class Ability

  include CanCan::Ability

  # -------------------------------------------------------------
  # Public: Initialize the Ability with the permissions of the specified
  # User.
  #
  # user - the user
  #
  def initialize(user)
    if user
      # This ability allows admins impersonating other users to revert
      # back to their original user.
      can :unimpersonate, User

      # A user should only be able to update himself or herself (assuming no
      # other permissions granted below by the global role).
      can [:show, :update], User do |target_user|
        target_user == user
      end

      can :index, User if user.global_role.can_edit_system_configuration?

      process_global_role user
      process_courses user
      process_assignments user
      process_repositories user
      process_assignment_checks user
      process_media_items user
    end
  end


  private

  # -------------------------------------------------------------
  # Private: Grant permissions from the user's global role.
  #
  # user - the user
  #
  def process_global_role(user)
    # Grant management access to most things through the
    # GlobalRole.can_edit_system_configuration? permission.
    #
    # TODO: This permission does too much. We probably want to separate
    # out things like ActivityLog, SystemConfiguration, User, and the roles
    # from Organization, for example.
    if user.global_role.can_edit_system_configuration?
      can :manage, ActivityLog
      can :manage, CourseRole
      can :manage, Environment
      can :manage, GlobalRole
      can :manage, Organization
      can :manage, Term
      can :manage, SystemConfiguration
      can :manage, User
      can :manage, ExampleRepository # FIXME make this right
    end

    # Grant broad course management access through the
    # GlobalRole.can_manage_all_courses? permission.
    if user.global_role.can_manage_all_courses?
      can :manage, Course
      can :manage, CourseOffering
      can :manage, CourseEnrollment
    end

    # Users with GlobalRole.can_create_courses? permission can create their
    # new courses and course offerings. The additional actions (updating and
    # deleting) will be determined by the CourseRole associated with their
    # enrollment.
    #
    # Notice that once a Course (not an offering) is created, that Course
    # may be used across multiple terms with multiple offerings, by many
    # different instructors. For this reason, once a Course is created, it
    # cannot be destroyed by anyone except someone with the
    # can_manage_all_courses? permission -- not even the user who originally
    # created it. Be careful.
    if user.global_role.can_create_courses?
      can :create, Course
      can :create, CourseOffering
    end
  end


  # -------------------------------------------------------------
  # Private: Process course-related permissions.
  #
  # user - the user
  #
  def process_courses(user)
    # A user can manage a CourseOffering if they are enrolled in that
    # offering and have a CourseRole where can_manage_course? is true.

    can :read, CourseOffering do |offering|
      user.course_offerings.include?(offering)
    end

    can :manage, CourseOffering do |offering|
      user.managing_course_offerings.include?(offering)
    end

    # Likewise, a user can only manage enrollments in a CourseOffering
    # that they have can_manage_courses? permission in.
    can :manage, CourseEnrollment do |enrollment|
      user_enrollment = CourseEnrollment.where(
        user_id: user.id,
        course_offering_id: enrollment.course_offering.id).first

      user_enrollment && user_enrollment.course_role.can_manage_course?
    end
  end


  # -------------------------------------------------------------
  # Private: Process assignment-related permissions.
  #
  # user - the user
  #
  def process_assignments(user)
    # A user can manage an Assignment if they have the
    # can_manage_assignments? permission in any of the CourseOfferings of
    # the Course that the assignment belongs to.
    #
    # TODO This may need improvement.
    can :manage, Assignment do |assignment|
      course = assignment.course
      course_offerings = course.course_offerings.joins(
        :course_enrollments => :course_role).where(
          course_enrollments: { user_id: user.id },
          course_roles: { can_manage_assignments: true }
        )

      course_offerings.any?
    end

    can :read, Assignment do |assignment|
      course = assignment.course
      course_offerings = course.course_offerings.joins(
        :course_enrollments).where(
          course_enrollments: { user_id: user.id }
        )

      course_offerings.any?
    end

    # A user can manage an AssignmentOffering in any CourseOffering where
    # they are enrolled and have the can_manage_assignments? permission.

    can :manage, AssignmentOffering do |offering|
      course_offering = offering.course_offering

      user_enrollment = CourseEnrollment.where(
        user_id: user.id,
        course_offering_id: course_offering.id).first

      user_enrollment && user_enrollment.course_role.can_manage_assignments?
    end

    # A user can read an AssignmentOffering in any course offering where
    # they are enrolled, period.

    can :read, AssignmentOffering do |offering|
      course_offering = offering.course_offering

      CourseEnrollment.where(
        user_id: user.id,
        course_offering_id: course_offering.id).any?
    end
  end


  # -------------------------------------------------------------
  # Private: Process repository-related permissions.
  #
  # user - the user
  #
  def process_repositories(user)    
    can :read, ExampleRepository do |repository|
      can? :read, repository.course_offering
    end

    can :manage, ExampleRepository do |repository|
      can? :manage, repository.course_offering.role_for_user(user).can_manage_assignments?
    end


    # Users can, of course, always read assignment repositories that
    # contain their own work. So can people enrolled in the same course
    # offering who have permission to view other students' submissions.
    can [:read, :update], AssignmentRepository do |repository|
      if repository.user == user
        true
      else
        co = repository.assignment_offering.course_offering
        role = co.role_for_user(user)
        role.can_view_other_submissions?
      end
    end


    # Users can manage the assignment reference repositories for assignments
    # that they can manage.
    # TODO probably make it so that only the creator can manage but other
    # instructors can edit
    can :read, AssignmentReferenceRepository do |repository|
      repository.assignment.assignment_offerings.any? do |ao|
        role = ao.course_offering.role_for_user(user)
        role.can_view_other_submissions?
      end
    end

    can :manage, AssignmentReferenceRepository do |repository|
      can? :manage, repository.assignment
    end


    can [:read, :update], ScratchpadRepository do |repository|
      user == repository.user
    end
  end


  # -------------------------------------------------------------
  # Private: Process assignment check-related permissions.
  #
  # user - the user
  #
  def process_assignment_checks(user)
    can :read, AssignmentCheck do |check|
      if check.assignment_repository.user == user
        true
      else
        co = check.assignment_repository.assignment_offering.course_offering
        role = co.role_for_user(user)
        role.can_view_other_submissions?
      end
    end
  end


  # -------------------------------------------------------------
  # Private: Process media item-related permissions.
  #
  # user - the user
  #
  def process_media_items(user)
    can :read, MediaItem do |item|
      item.user == user || (item.assignment && can?(:read, item.assignment))
    end

    can :manage, MediaItem do |item|
      item.user == user || (item.assignment && can?(:manage, item.assignment))
    end
  end

end
