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
  # def code_path(model)
  #   path_parts = []

  #   if model.is_a?(ExampleRepository)
  #     model = model.course
  #   end

  #   if model.is_a?(Course)
  #     path_parts.unshift course.url_part
  #     model = 
  #   end

  #   course = offering.course
  #   term = offering.term
  #   institution = course.department.institution

  #   "/home/#{institution.url_part}/#{term.url_part}/#{course.url_part}/#{offering.crn}"
  # end


end
