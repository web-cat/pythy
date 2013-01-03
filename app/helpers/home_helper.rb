module HomeHelper

  # -------------------------------------------------------------
  def course_exists?
    @institution && @term && @course
  end


  # -------------------------------------------------------------
  def course_offering_home_path(offering)
    course = offering.course
    term = offering.term
    institution = course.department.institution

    "/home/#{institution.url_part}/#{term.url_part}/#{course.url_part}/#{offering.crn}"
  end


  # -------------------------------------------------------------
  def code_path(model)
    path_parts = []

    if model.is_a?(ExampleRepository)
      # TODO use a friendlier name
      path_parts.unshift model.id.to_s
      path_parts.unshift 'example'
      model = model.course_offering
    end

    if model.is_a?(CourseOffering)
      path_parts.unshift model.crn.to_s
      path_parts.unshift model.course.url_part
      path_parts.unshift model.term.url_part
      model = model.course.department.institution
    end

    if model.is_a?(Institution)
      path_parts.unshift model.url_part
      model = nil
    end

    path_parts.unshift 'code'

    '/' + File.join(path_parts)
  end


end
