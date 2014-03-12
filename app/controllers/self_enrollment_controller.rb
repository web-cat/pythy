class SelfEnrollmentController < ApplicationController

  # -------------------------------------------------------------
  def select_organization
    @organization = Organization.find_by_id(params[:organization])

    if @organization
      @term_list = Term.all.map { |term| [term.display_name, term.id] }
    end

    respond_to do |format|
      format.js
    end
  end


  # -------------------------------------------------------------
  def select_term
    @organization = Organization.find_by_id(params[:organization])
    @term = Term.find_by_id(params[:term])

    if @organization && @term
      offerings = CourseOffering.joins(:course).where(
        courses: { organization_id: @organization.id },
        term_id: @term.id,
        self_enrollment_allowed: true).reject { |offering| offering.user_enrolled?(current_user) }

      @courses = offerings.group_by { |offering| offering.course }
    end 

    respond_to do |format|
      format.js
    end
  end


  # -------------------------------------------------------------
  def enroll
    course_offering = CourseOffering.find_by_id(params[:course_offering])

    respond_to do |format|
      if course_offering && course_offering.self_enrollment_allowed?
        enrollment = CourseEnrollment.create(
          course_offering_id: course_offering.id,
          user_id: current_user.id,
          course_role_id: CourseRole.student.id)
          
        course = course_offering.course
        term = course_offering.term

        format.html { redirect_to view_context.home_path(course, term: term) }
      else
        format.html { forbidden }
      end
    end
  end

end
